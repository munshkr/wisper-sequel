module Sequel
  module Plugins
    module Wisper
      def self.apply(model, *attrs)
        require 'sequel/extensions/inflector'
        require 'wisper'

        model.send(:include, ::Wisper::Publisher)
      end

      def self.configure(model, *attrs)
      end

      module ClassMethods
      end

      module InstanceMethods
        def save
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
        end

        def before_update
          broadcast(:before_update, self)
          super
        end

        def after_update
          super
          broadcast(:after_update, self)
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
        end

        def after_destroy_rollback
          super
          broadcast(:after_destroy_rollback, self)
        end

        def around_validation
          res = super
        rescue => error
          res = nil
        ensure
          if !res && on_save?
            if new?
              broadcast(:"create_#{model_name}_failed", self)
            else
              broadcast(:"update_#{model_name}_failed", self)
            end
          end
          raise error if error
        end

        def around_create
          res = super
        rescue => error
          res = nil
        ensure
          if res
            broadcast(:"create_#{model_name}_successful", self)
          else
            broadcast(:"create_#{model_name}_failed", self)
          end
          raise error if error
        end

        def around_update
          res = super
        rescue => error
          res = nil
        ensure
          if res
            broadcast(:"update_#{model_name}_successful", self)
          else
            broadcast(:"update_#{model_name}_failed", self)
          end
          raise error if error
        end

        def around_destroy
          res = super
        rescue => error
          res = nil
        ensure
          if res
            broadcast(:"destroy_#{model_name}_successful", self)
          else
            broadcast(:"destroy_#{model_name}_failed", self)
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

      module DatasetMethods
      end
    end
  end
end
