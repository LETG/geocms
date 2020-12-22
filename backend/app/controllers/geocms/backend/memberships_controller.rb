#encoding: utf-8
module Geocms
  module Backend
    class MembershipsController < Geocms::Backend::ApplicationController
      def create
        user = User.where(email: params[:user_email]).first
        membership = Membership.new
        membership.user = user
        membership.account = current_tenant
        membership.save
        redirect_to :backend_users
      end
    end
  end
end
