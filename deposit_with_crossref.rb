require "faraday"
require "faraday/multipart"

crossref_filepath = ENV['CROSSREF_FILEPATH']
crossref_username = ENV['CROSSREF_USERNAME']
crossref_password = ENV['CROSSREF_PASSWORD']
mode = ENV['CROSSREF_MODE']

crossref_url = "https://doi.crossref.org"
crossref_path = "/servlet/deposit"
params = { login_id: crossref_username, login_passwd: crossref_password }

crossref_url = "https://test.crossref.org" if mode.to_s.downcase == "test"

if File.exist?(crossref_filepath)
  system("echo 'Depositing with Crossref...'")
  conn = Faraday.new(crossref_url) do |f|
    f.request :multipart
  end

  payload = params
  payload[:fname] = Faraday::FilePart.new(File.new(crossref_filepath, 'rb'), "application/xml")

  deposit_call = conn.post(crossref_path, payload)

  if deposit_call.status.between?(200, 299)
    system("echo 'Deposit looks good.'")
  else
    system("echo 'CUSTOM_ERROR=Could not deposit with Crossref.' >> $GITHUB_ENV")
    raise "!! ERROR: Something went wrong with this deposit call to Crossref"
  end
else
  system("echo 'CUSTOM_ERROR=Could not deposit with Crossref.' >> $GITHUB_ENV")
  raise "!! ERROR: Can't deposit Crossref metadata - deposit XML is missing"
end

