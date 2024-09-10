every '0 0 1 * *' do
  runner "MonthlyMailer.summary_email.deliver_now"
end
