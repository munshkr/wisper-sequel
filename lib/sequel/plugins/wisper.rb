module Sequel
  module Plugins
    module Wisper
      def self.apply(model, *attrs)
      end

      def self.configure(model, *attrs)
      end

      module ClassMethods
      end

      module InstanceMethods
        def before_validation
          puts 'before_validation'
          super
        end

        def after_validation
          super
          puts 'after_validation'
        end

        def before_save
          puts 'before_save'
          super
        end

        def after_save
          super
          puts 'after_save'
        end

        def before_create
          puts 'before_create'
          super
        end

        def after_create
          super
          puts 'after_create'
        end

        def before_update
          puts 'before_update'
          super
        end

        def after_update
          super
          puts 'after_update'
        end

        def before_destroy
          puts 'before_destroy'
          super
        end

        def after_destroy
          super
          puts 'after_destroy'
        end

        def after_commit
          super
          puts 'after_commit'
        end

        def after_rollback
          super
          puts 'after_rollback'
        end

        def after_destroy_commit
          super
          puts 'after_destroy_commit'
        end

        def after_destroy_rollback
          super
          puts 'after_destroy_rollback'
        end
      end

      module DatasetMethods
      end
    end
  end
end
