require 'features/features_spec_helper'
require "support/features/form_helpers.rb"

feature "Customer settings: addresses." do
  include Features::FormHelpers

  given(:customer) { FactoryGirl.create(:customer) }
  given(:billing_address) { FactoryGirl.create(:address) }
  given(:shipping_address) { FactoryGirl.create(:address) }
  
  before do 
    login_as(customer, scope: :customer)
    @countries = FactoryGirl.create_list(:country, 3)
    visit settings_path
  end

  context "customer tries to subbmit billing or address form with blank fields" do 
    shared_examples "address form" do
      describe "form" do
        it "displays errors when submitted with blank fields" do
          within form do
            click_button('Save')
          end
          expect(page).to have_content "You've got some errors. Check it below."
          expect(page).to have_content "Address can't be blank"
          expect(page).to have_content "Zipcode can't be blank"
          expect(page).to have_content "City can't be blank"
          expect(page).to have_content "Phone can't be blank"
          expect(page).to have_content "Lastname can't be blank"
          expect(page).to have_content "Firstname can't be blank"
        end
      end
    end

    it_behaves_like "address form" do
      let(:form) { '#new_address.billing-address-form' } 
    end

    it_behaves_like "address form" do 
      let(:form) { '#new_address.shipping-address-form' } 
    end
  end

  context "customer don't have billing address and shipping address" do
    scenario "customer successfully create billing address via form and shipping address assigns the same", js: true do 
      fill_address_form('#new_address.billing-address-form') 
      expect(page).to have_content 'Billing address was successfully created.'
      expect(page).to have_selector '#edit_address_1.billing-address-form'
      expect(page).to have_selector '#edit_address_1.shipping-address-form'
    end

    scenario "customer successfully create shipping address via form and billing address remain blank", js: true do 
      within "#new_address.shipping-address-form" do 
        uncheck('Use billing address')
      end
      fill_address_form('#new_address.shipping-address-form') 
      expect(page).to have_content 'Shipping address was successfully created.'
      expect(page).to have_selector '#edit_address_1.shipping-address-form'
      expect(page).to have_selector '#new_address.billing-address-form'
    end
  end

  context "customer have only shipping address" do
    before do
      customer.update(shipping_address: shipping_address)
      visit settings_path
    end
    scenario "customer successfully create billing address via form and shipping address doesn't changes", js: true do 
      fill_address_form('#new_address.billing-address-form') 
      expect(page).to have_content 'Billing address was successfully created.'
      expect(page).to have_selector '#edit_address_2.billing-address-form'
      expect(page).to have_selector '#edit_address_1.shipping-address-form'
    end

    scenario "customer tries to save shipping address form with checked 'Use billing address'", js: true do 
      within "#edit_address_1.shipping-address-form" do 
        check('Use billing address')
        click_button('Save')
      end 
      expect(page).to have_content "You can't use billing address as shipping because you don't have it yet"
      expect(page).to have_selector '#new_address.billing-address-form'
      expect(page).to have_selector '#edit_address_1.shipping-address-form'
    end
  end

  context "customer have billing and different shipping address" do 
    before do
      customer.update(billing_address: billing_address, shipping_address: shipping_address)
      visit settings_path
    end

    scenario "customer successfully update billing address via form and shipping address doesn't changes", js: true do 
      fill_address_form('#edit_address_1.billing-address-form') 
      expect(page).to have_content 'Billing address was successfully updated.'
      expect(page).to have_selector '#edit_address_1.billing-address-form'
      expect(page).to have_selector '#edit_address_2.shipping-address-form'
    end

    scenario "customer successfully update shipping address via form and billing address doesn't changes", js: true do
      within "#edit_address_2.shipping-address-form" do 
        uncheck('Use billing address')
      end 
      fill_address_form('#edit_address_2.shipping-address-form') 
      expect(page).to have_content 'Shipping address was successfully updated.'
      expect(page).to have_selector '#edit_address_1.billing-address-form'
      expect(page).to have_selector '#edit_address_2.shipping-address-form'
    end

    scenario "customer save shipping address with chacked 'Use billing address' - billing address assigns also as shipping", js: true do
      within "#edit_address_2.shipping-address-form" do 
        check('Use billing address')
        click_button('Save')
      end 
      expect(page).to have_content 'Now we will use your billing address also as shipping.'
      expect(page).to have_selector '#edit_address_1.billing-address-form'
      expect(page).to have_selector '#edit_address_1.shipping-address-form'
    end
  end

  context "customer have billing and same shipping address" do 
    before do
      customer.update(billing_address: billing_address, shipping_address: billing_address)
      visit settings_path
    end

    scenario "save shipping address form with unchecked 'Use billing address' (optionally editing sip address info)", js: true do
      within "#edit_address_1.shipping-address-form" do 
        uncheck('Use billing address')
        click_button('Save')
      end 
      expect(page).to have_content 'Shipping address was successfully created.'
      expect(page).to have_selector '#edit_address_1.billing-address-form'
      expect(page).to have_selector '#edit_address_2.shipping-address-form'
    end

    scenario "update billing address" do 
      within "#edit_address_1.billing-address-form" do 
        fill_in "First name", with: "Mario"
        click_button('Save')
      end
      expect(page).to have_content "Billing address was successfully updated." 
      expect(Address.all.size).to eq 1 
      expect(Address.last.firstname).to eq "Mario" 
    end
  end


  describe "'Use billing address' checkbox:" do
    scenario "it chaked and shipping address form hidden", js: true do
      within "#new_address.shipping-address-form" do 
        check('Use billing address')
      end
      expect(page).not_to have_selector "#new_address.shipping-address-form .ship-address-form-fields" 
    end

    scenario "it unchecked and shipping address form visible", js: true do
      within "#new_address.shipping-address-form" do 
        uncheck('Use billing address')
      end
      expect(page).to have_selector "#new_address.shipping-address-form .ship-address-form-fields" 
    end
  end
end

