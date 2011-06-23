%% @author Michael Connors <michael@bring42.net>
%% @copyright 2011 Michael Connors
%% @date 2011-04-21
%% @doc Avatar Module.

%% Copyright 2011 Michael Connors
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(mod_avatar).
-author("Michael Connors <michael@bring42.net>").

-mod_title("Avatar Module").
-mod_description("Upload an avatar to associate with your user account.").
-mod_prio(500).

-include_lib("zotonic.hrl").

%% interface functions
-export([
    init/1,
    event/2
]).


init(Context) ->
    z_datamodel:manage(?MODULE, datamodel(), Context).


event({submit, {avatar_upload, _Args}, _TriggerId, _TargetId}, Context) ->
    File = z_context:get_q_validated("upload_file", Context),
    UserId = z_acl:user(Context),
    case m_rsc:p(UserId, title, Context) of
        undefined -> 
            Context1 = z_render:update("notifications", "<p>You are not logged in!</p>", Context),
            Context1;
        Title ->
            case File of
                #upload{filename=OriginalFilename, tmpfile=TmpFile} ->
                    Props = [{title, list_to_binary(binary_to_list(Title)++" Avatar")}, {original_filename, OriginalFilename}],
                    case z_media_identify:identify(File, Context) of
                        {ok, Info} ->
                            Mime = proplists:get_value(mime, Info),
                            case Mime of
                                "image/jpeg" ->
                                    case m_rsc:o(UserId, has_avatar, 1, Context) of
                                        undefined ->
                                            handle_media_upload(UserId, fun(Ctx) -> m_media:insert_file(TmpFile, Props, Ctx) end, Context);
                                        Id ->
                                            handle_media_upload(Id, UserId, fun(Id, Ctx) -> m_media:replace_file(TmpFile, Id, Ctx) end, Context)
                                    end;
                                _Other -> z_render:update("notifications", "<p>Your avatar must be a JPEG</p>", Context)
                            end;
                        {error, _Reason} -> z_render:update("notifications", "<p>Error uploading avatar</p>", Context)
                    end;
                _ ->
                    Context
            end
        end.


% support functions

handle_media_upload(Id, _UserId, ReplaceFun, Context) ->
    case ReplaceFun(Id, Context) of
        {ok, _} ->
            Html = z_template:render("_render_avatar.tpl", [], Context),
            z_render:update("avatar", Html, Context);
        {error, eacces} ->
            z_render:update("notifications", "<p>Access denied</p>", Context);
        {error, _} ->
            z_render:update("notifications", "<p>Error uploading avatar</p>", Context)
    end.


%% Handling the media upload.
handle_media_upload(UserId, InsertFun, Context) ->
    F = fun(Ctx) ->
            case InsertFun(Ctx) of
                {ok, MediaRscId} ->
                    m_edge:insert(UserId, "has_avatar", MediaRscId, Ctx),
                    {ok, MediaRscId};
                Error -> 
                    Error
            end
        end,
    Result = z_db:transaction(F, Context),
    case Result of
        {ok, _MediaId} ->
            Html = z_template:render("_render_avatar.tpl", [], Context),
            z_render:update("avatar", Html, Context);
        {error, _Error} ->
            z_render:update("notifications", "<p>Upload failed</p>", Context)
    end.

datamodel() ->
    [{categories,
      [
       {avatar,
        image,
        [{title, <<"Avatar">>}]}
      ]
     },
     {predicates,
      [
       {has_avatar,
        [{title, <<"Avatar">>}],
        [{person, image}]}
      ]
     }
    ].
