module Sequel
  module Plugins
    module Wisper
      def self.apply(model, opts={})
        require 'sequel/extensions/inflector'
        require 'wisper'

        model.send(:include, ::Wisper::Publisher)
      end

      def self.configure(model, opts={})
        model.instance_eval do
          @event_param_block = opts[:event_param_block]
        end
      end

      module ClassMethods
        def event_param_block
          @event_param_block
        end
      end

      module InstanceMethods
        def save(*args)
          on_save { super }
        end

        def before_validation
          broadcast(:before_validation, event_param)
          super
        end

        def after_validation
          super
          broadcast(:after_validation, event_param)
        end

        def before_save
          broadcast(:before_save, event_param)
          super
        end

        def after_save
          super
          broadcast(:after_save, event_param)
        end

        def before_create
          broadcast(:before_create, event_param)
          super
        end

        def after_create
          super
          broadcast(:after_create, event_param)
          db.after_commit { broadcast(:"create_#{model_name}_successful", event_param) }
          db.after_rollback { broadcast(:"create_#{model_name}_failed", event_param) }
        end

        def before_update
          broadcast(:before_update, event_param)
          super
        end

        def after_update
          super
          broadcast(:after_update, event_param)
          db.after_commit { broadcast(:"update_#{model_name}_successful", event_param) }
          db.after_rollback { broadcast(:"update_#{model_name}_failed", event_param) }
        end

        def before_destroy
          broadcast(:before_destroy, event_param)
          super
        end

        def after_destroy
          super
          broadcast(:after_destroy, event_param)
        end

        def after_commit
          super
          broadcast(:after_commit, event_param)
        end

        def after_rollback
          super
          broadcast(:after_rollback, event_param)
        end

        def after_destroy_commit
          super
          broadcast(:after_destroy_commit, event_param)
          broadcast(:"destroy_#{model_name}_successful", event_param)
        end

        def after_destroy_rollback
          super
          broadcast(:after_destroy_rollback, event_param)
          broadcast(:"destroy_#{model_name}_failed", event_param)
        end

        def around_validation
          res = super
        rescue => error
          res = nil
        ensure
          if on_save? && !res
            action = new? ? 'create' : 'update'
            broadcast(:"#{action}_#{model_name}_failed", event_param)
          end
          raise error if error
        end

        private

        def model_name
          model.name.underscore
        end

        def on_save
          @on_save = true
          yield
        ensure
          @on_save = nil
        end

        def on_save?
          @on_save
        end

        def event_param
          event_param_block ? event_param_block.call(self) : self
        end

        def event_param_block
          self.class.event_param_block
        end
      end
    end
  end
end
