require_relative "lib/tariff_diff"

task default: %w[tariff:diff]

namespace :tariff do
  desc "See what data is different between two Tariff API endpoints. It traverses chapters tree and compares chapters, headings and commodities between two endpoints"
  task :chapters_diff, [:host1, :host2] do |t, args|
    # if the host requires authentication, set username and password to env
    # variables. eg:
    # rake tariff:chapters_diff[host1,host2]
    # rake tariff:chapters_diff[host1,host2] host1user=username host1passwd=secret host2user=username host2passwd=secret
    # Example:
    # `rake tariff:diff[https://www.gov.uk/,http://tariff.dev.gov.uk/] host2user=macool host2passwd=marioandres`
    TariffDiff.new(args).chapters_diff!
  end

  desc "See what updates are different on two tariff api endpoints"
  task :updates_diff, [:host1, :host2] do |t, args|
    TariffDiff.new(args).updates_diff!
  end
end
