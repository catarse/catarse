module ContributionSpecHelpers
  def create_contribution_with_payment(project_id, payment_state)
    c = create(:confirmed_contribution, value: 10.0, project_id: project_id)
    c.payments.first.update(gateway_fee: 1, state: payment_state)
    c
  end
end
