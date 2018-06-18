# frozen_string_literal: true

# Rails has eager loading code for production multithreaded apps
# but due to a bug this code is not initialized.
# Once the following PR is merged, this patch can be removed:
# https://github.com/rails/rails/pull/33054

module Rails
  class Application
    class RoutesReloader
      # rails/railties/lib/rails/application/routes_reloader.rb
      # delegate :execute_if_updated, :execute, to: :updater

      def reload!
        puts 'RoutesReloader::reload!'
        clear!
        load_paths
        finalize!
        # route_sets.each(&:eager_load!) if eager_load
      ensure
        revert
      end

      def execute
        puts 'RoutesReloader::execute'
        ret = updater.execute
        route_sets.each(&:eager_load!) if eager_load
        ret
      end

      def execute_if_updated
        puts 'RoutesReloader::execute_if_updated'
        if updated = updater.execute_if_updated
          puts 'RoutesReloader::execute_if_updated eager loading routes'
          route_sets.each(&:eager_load!) if eager_load
        end
        updated
      end
    end
  end
end

module ActionDispatch
  module Journey
    class Routes
      # rails/actionpack/lib/action_dispatch/journey/routes.rb
      def simulator
        return if ast.nil?
        @simulator ||= begin
          gtg = GTG::Builder.new(ast).transition_table
          GTG::Simulator.new(gtg)
        end
      end
    end
  end
end

module ActionDispatch
  module Routing
    class RouteSet
      # rails/actionpack/lib/action_dispatch/routing/route_set.rb
      def eager_load!
        puts 'RouteSet::eager_load!'
        router.eager_load!
        routes.each(&:eager_load!)
        nil
      end
    end
  end
end
