class Api::V1::MyPostsController < Api::ApiController
  inherit_resources
  defaults :resource_class => Post, :collection_name => 'posts', :instance_name => 'post'
  actions :index, :show, :create, :update, :destroy
  has_scope :page, :default => 1

  doorkeeper_for :all

  def show
    show! do
      if @post.nil?
        @error = ApiError.new(
          :resource_not_found,
          "Not Found",
          "Requested post does not exist or you don't have permission to see it."
        )
        render :action => :error
        return
      end
    end
  end

  def create
    @post = current_user.posts.build(
      :title => params[:title],
      :content => params[:content],
      :published_at => params[:published] == "true" ? Time.now : nil
    )
    create! do |success, failure|
      failure.json do
        logger.debug @post.errors.inspect
        @error = ApiError.new(
          :invalid_parameter,
          "Parameter Error",
          @post.errors.messages
        )
        render :action => :error
      end
      success.json do
        redirect_to resource_url
      end
    end
  end

  private

  def begin_of_association_chain
    current_user
  end
end