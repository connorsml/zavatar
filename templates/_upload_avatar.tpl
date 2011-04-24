<div id="notifications">&nbsp;</div>
{% wire id=#form type="submit" postback={avatar_upload } delegate="mod_avatar" %}
<form id="{{ #form }}" method="POST" action="postback">
	<div class="new-media-wrapper">
		<div class="form-item clearfix">
			<label for="upload_file">{_ Media file _}</label>
			<input type="file" id="upload_file" name="upload_file" />
			{% validate id="upload_file" type={presence} %}
		</div>

		<div class="form-item clearfix">
			<button type="submit">{_ Upload file _}</button>
		</div>
	</div>
</form>