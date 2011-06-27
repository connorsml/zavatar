{% if verified_user_id|is_defined %}
    <div class="avatar">
        {% with m.rsc[verified_user_id] as user %}
            {% if m.rsc[verified_user_id].has_avatar[1]|is_defined %}
                {% image m.rsc[verified_user_id].has_avatar.id crop width=120 height=160 %}
            {% else %}
                <img src="/lib/images/nobody.png" alt="pseudo" />
            {% endif %}
        {% endwith %}
    </div>
{% else %}
    <div id="avatar">
    {% with m.acl.user as user_id %}
        {% if user_id  %}
            {% with m.rsc[user_id] as user %}
                {% if m.rsc[user_id].has_avatar[1]|is_defined %}
                    {% image m.rsc[user_id].has_avatar.id crop width=120 height=160 %}
                {% else %}
                    <img src="/lib/images/nobody.png" alt="pseudo" />
                {% endif %}
            {% endwith %}
        {% endif %}
    {% endwith %}
    </div>
{% endif %}