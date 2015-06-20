module Sequel
  module Plugins
    module Wisper
      def self.apply(model, *attrs)
        model.send(:include, ::Wisper::Publisher)
      end

      def self.configure(model, *attrs)
      end

      module ClassMethods
      end

      module InstanceMethods
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

        def broadcast(*args, &block)
          logger.info "broadcast(#{args})"
          super
        end

        private

        def model_name
          model.name.underscore
        end
      end

      module DatasetMethods
      end
    end
  end
end
