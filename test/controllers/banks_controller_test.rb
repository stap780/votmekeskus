require 'test_helper'

class BanksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bank = banks(:one)
  end

  test "should get index" do
    get banks_url
    assert_response :success
  end

  test "should get new" do
    get new_bank_url
    assert_response :success
  end

  test "should create bank" do
    assert_difference('Bank.count') do
      post banks_url, params: { bank: { app_address: @bank.app_address, app_type: @bank.app_type, bank_shop_id: @bank.bank_shop_id, bank_shop_id_test: @bank.bank_shop_id_test, ins_fail_url: @bank.ins_fail_url, ins_password: @bank.ins_password, ins_success_url: @bank.ins_success_url } }
    end

    assert_redirected_to bank_url(Bank.last)
  end

  test "should show bank" do
    get bank_url(@bank)
    assert_response :success
  end

  test "should get edit" do
    get edit_bank_url(@bank)
    assert_response :success
  end

  test "should update bank" do
    patch bank_url(@bank), params: { bank: { app_address: @bank.app_address, app_type: @bank.app_type, bank_shop_id: @bank.bank_shop_id, bank_shop_id_test: @bank.bank_shop_id_test, ins_fail_url: @bank.ins_fail_url, ins_password: @bank.ins_password, ins_success_url: @bank.ins_success_url } }
    assert_redirected_to bank_url(@bank)
  end

  test "should destroy bank" do
    assert_difference('Bank.count', -1) do
      delete bank_url(@bank)
    end

    assert_redirected_to banks_url
  end
end
