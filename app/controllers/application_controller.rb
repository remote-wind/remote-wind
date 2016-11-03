class ApplicationController < ActionController::Base
  include Pundit
  include ActionView::Helpers::TextHelper

  protect_from_forgery with: :exception
  before_filter :get_notifications, if: -> { user_signed_in? }

  # OPT OUT security model
  before_filter :authenticate_user!, unless: -> { user_signed_in? }

  # Ensures that different types of representations of a resource are NOT given the same etag.
  # @see https://github.com/rails/rails/issues/17129
  etag { request.format }
  # Avoid cache issues when a user is either given a cached page she is no longer allowed to view (after logging out)
  # or a page with authorized features missing.
  etag { user_signed_in? ? current_user.id : 0 }

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    html_tag.html_safe
  end

  # Handle authentication errors
  # @todo store original request url in session and redirect after sign in.
  rescue_from Pundit::NotAuthorizedError do |exception|
    if user_signed_in?
      redirect_to root_url
    else
      redirect_to new_user_session_path
    end
  end

  private

    # Get notifications
    #@todo load with ajax instead
    def get_notifications
      count = Notification.where(user: current_user, read: false).count
      if count > 0
        flash[:notice] = view_context.link_to(
            "You have #{pluralize(count, 'unread notification')}.", notifications_path
        )
        @unread_notifications_count = count
      end
    end

    # Tell devise to redirect to root instead of user#show
    def after_sign_in_path_for(resource)
      root_path
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      root_path
    end

    # ActiveRecord::Serializers
    # Don´t emit node per default when serializing
    def default_serializer_options
      {root: false}
    end

    # Enables cross-origin resource sharing for action.
    # @see http://enable-cors.org/index.html
    # @see https://github.com/remote-wind/remote-wind/issues/94
    def make_public(
      origin: '*',
      methods: 'GET, OPTIONS',
      headers: 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    )
      self.headers['Access-Control-Allow-Origin'] = origin
      self.headers['Access-Control-Allow-Methods'] = methods
      self.headers['Access-Control-Allow-Headers'] = headers
    end

    def self.member_actions
      [:show, :edit, :update, :destroy]
    end

    def self.collection_actions
      [:new, :create, :index]
    end
end
