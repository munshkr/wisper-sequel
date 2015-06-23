module Sequel
  module Plugins
    module Wisper
      def self.apply(model, *attrs)
        require 'sequel/extensions/inflector'
        require 'wisper'

        model.send(:include, ::Wisper::Publisher)
      end

      module InstanceMethods
        def save(*args)
          on_save { super }
        end

        def before_validation
          broadcast(:before_validation, self)
          super
        end

        def after_validation
          super
          broadcast(:after_validation, self)
        end

        def before_save
          broadcast(:before_save, self)
          super
        end

        def after_save
          super
          broadcast(:after_save, self)
        end

        def before_create
          broadcast(:before_create, self)
          super
        end

        def after_create
          super
          broadcast(:after_create, self)
          db.after_commit { broadcast(:"create_#{model_name}_successful", self) }
          db.after_rollback { broadcast(:"create_#{model_name}_failed", self) }
        end

        def before_update
          broadcast(:before_update, self)
          super
        end

        def after_update
          super
          broadcast(:after_update, self)
          db.after_commit { broadcast(:"update_#{model_name}_successful", self) }
          db.after_rollback { broadcast(:"update_#{model_name}_failed", self) }
        end

        def before_destroy
          broadcast(:before_destroy, self)
          super
        end

        def after_destroy
          super
          broadcast(:after_destroy, self)
        end

        def after_commit
          super
          broadcast(:after_commit, self)
        end

        def after_rollback
          super
          broadcast(:after_rollback, self)
        end

        def after_destroy_commit
          super
          broadcast(:after_destroy_commit, self)
          broadcast(:"destroy_#{model_name}_successful", self)
        end

        def after_destroy_rollback
          super
          broadcast(:after_destroy_rollback, self)
          broadcast(:"destroy_#{model_name}_failed", self)
        end

        def around_validation
          res = super
        rescue => error
          res = nil
        ensure
          if on_save? && !res
            action = new? ? 'create' : 'update'
            broadcast(:"#{action}_#{model_name}_failed", self)
          end
          raise error if error
        end

        private

        def model_name
          model.name.underscore
        end

        def on_save
          @on_save ||= 0
          @on_save += 1
          yield
        ensure
          @on_save -= 1
        end

        def on_save?
          @on_save && @on_save > 0
        end
      end
    end
  end
end
