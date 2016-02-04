# -*- encoding : utf-8 -*-
require 'builder'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Toggle < RailsAdmin::Config::Fields::Base
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
          include RailsAdmin::Engine.routes.url_helpers

          register_instance_option :view_helper do
            :check_box
          end

          register_instance_option :pretty_value do
            def g_js
              <<-END.strip_heredoc.gsub("\n", ' ').gsub(/ +/, ' ')
                var $t = $(this);
                $t.html("<i class='fa fa-spinner fa-spin'></i>");
                $.ajax({
                  type: "POST",
                  url: $t.attr("href"),
                  data: {ajax:true},
                  success: function(r) {
                    $t.attr("href", r.href);
                    $t.attr("class", r.class);
                    $t.text(r.text);
                    $t.parent().attr("title", r.text);
                    $t.siblings(".toggle-btn").remove();
                  },
                  error: function(e) {
                    alert(e.responseText);
                  }
                });
                return false;
              END
            end
            def g_link(fv, on, badge)
              bindings[:view].link_to(
                fv.html_safe,
                toggle_path(
                    model_name: @abstract_model, id: bindings[:object].id, method: name, on: on.to_s,
                    locale: I18n.locale.empty? ? nil : I18n.locale
                ),
                # method: :post,
                class: 'toggle-btn label ' + badge,
                onclick: g_js
              )
            end

            case value
              when nil
              when false
                g_link('✘', 1, 'label-danger')
              when true
                g_link('✓', 0, 'label-success')
              else
                %{<span class="label">-</span>}
            end.html_safe
          end

          register_instance_option :export_value do
            value.inspect
          end

          # Accessor for field's help text displayed below input field.
          register_instance_option :help do
            ""
          end
        end
      end
    end
  end
end
