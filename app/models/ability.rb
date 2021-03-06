class Ability
  include CanCan::Ability

  def initialize(user)
      user ||= Customer.new # guest user (not logged in)
      can :read, [Book, Category]
      if user.is_a?(Admin)
        can :manage, :all
        can :access, :rails_admin   # grant access to rails_admin
        can :dashboard              # grant access to the dashboard
      elsif user.id?
        can :manage, Address, id: [user.billing_address_id, user.shipping_address_id] 
        can :read, Order, customer_id: user.id
      end
  end
end
