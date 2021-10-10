require "application_system_test_case"

class BanksTest < ApplicationSystemTestCase
  setup do
    @bank = banks(:one)
  end

  test "visiting the index" do
    visit banks_url
    assert_selector "h1", text: "Banks"
  end

  test "creating a Bank" do
    visit banks_url
    click_on "New Bank"

    fill_in "App address", with: @bank.app_address
    check "App type" if @bank.app_type
    fill_in "Bank shop", with: @bank.bank_shop_id
    fill_in "Bank shop id test", with: @bank.bank_shop_id_test
    fill_in "Ins fail url", with: @bank.ins_fail_url
    fill_in "Ins password", with: @bank.ins_password
    fill_in "Ins success url", with: @bank.ins_success_url
    click_on "Create Bank"

    assert_text "Bank was successfully created"
    click_on "Back"
  end

  test "updating a Bank" do
    visit banks_url
    click_on "Edit", match: :first

    fill_in "App address", with: @bank.app_address
    check "App type" if @bank.app_type
    fill_in "Bank shop", with: @bank.bank_shop_id
    fill_in "Bank shop id test", with: @bank.bank_shop_id_test
    fill_in "Ins fail url", with: @bank.ins_fail_url
    fill_in "Ins password", with: @bank.ins_password
    fill_in "Ins success url", with: @bank.ins_success_url
    click_on "Update Bank"

    assert_text "Bank was successfully updated"
    click_on "Back"
  end

  test "destroying a Bank" do
    visit banks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bank was successfully destroyed"
  end
end
