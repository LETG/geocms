module Geocms
  module Backend
    class UsersController < Geocms::Backend::ApplicationController
      load_and_authorize_resource class: "Geocms::User"

      rescue_from CanCan::AccessDenied do |exception|
        controle_access(exception)
      end

      def index
        @users = current_tenant.users
        @users += Geocms::User.joins(:roles).where("geocms_roles.name='admin'").all
        @users = @users.uniq

        @others_users = User.where.not(id: @users.pluck(:id)).select("id","email").to_json.html_safe

        @isAdmin = current_user.has_role? :admin 
        @isAdmin_instance = current_user.has_role? :admin_instance 

        @membership = Membership.new

        respond_with(:backend, @users)

      end

      def network
        respond_to do |format|
          format.json { render json: User.network_json }
        end
      end

      def add
        @user = User.where(username: params[:username]).first
        current_tenant.users << @user
        current_tenant.save
       # render "_user", locals: { user: @user }, layout: false
      end

      def new
        @user = User.new
        @user.add_role :user

        if (current_user.has_role? :admin) 
          @disable_admin=false
        else
          @disable_admin=true
        end

        @available_roles=Geocms::Role::available_roles(@disable_admin)

        respond_with(:backend, @user)
      end

      def create
        @user = User.new(user_params)

        if (!(current_user.has_role? :admin) && (@user.has_role? :admin))
          redirect_to backend_users_url
        else 
           @user.update_attributes(user_params)
        
          # default role is :user
          if @user.roles.to_a.empty?
            @user.add_role :user
          end

          @user.save
          current_tenant.users << @user
         
          respond_with(:backend, :users)
        end
      end

      def edit
        @user = User.find(params[:id])

        if (!(current_user.has_role? :admin) && (@user.has_role? :admin))
          redirect_to backend_users_url
        end

        if (current_user.has_role? :admin) 
          @disable_admin=false
        else
          @disable_admin=true
        end

        @available_roles=Geocms::Role::available_roles(@disable_admin)
      end

      def update
        @user = User.find(params[:id])

        if (!(current_user.has_role? :admin) && (@user.has_role? :admin))
          redirect_to backend_users_url
        else
          @user.update_attributes(user_params)
          respond_with(:backend, :users)
        end
      end

      def destroy
        @user = User.find(params[:id])

        if (!(current_user.has_role? :admin) && (@user.has_role? :admin))
          redirect_to backend_users_url
        else 
          current_tenant.users.delete(@user)
    
          respond_with(:backend, :users)
        end
      end

      private
        def user_params
          params.require(:user).permit(PermittedAttributes.user_attributes,:role_ids => []) 
        end

    end
  end
end
