require_relative "lib/tariff_diff"

task default: %w[tariff:diff]

namespace :tariff do
  desc "See what data is different between two Tariff API endpoints. It traverses the tree and compares all nodes between two endpoints"
  task :diff, [:host1, :host2] do |t, args|
    # if the host requires authentication, set username and password to env
    # variables. eg:
    # rake tariff:diff[host1,host2]
    # rake tariff:diff[host1,host2] host1user=username host1passwd=secret host2user=username host2passwd=secret
    # Example:
    # `rake tariff:diff[https://www.gov.uk/,http://tariff.dev.gov.uk/] host2user=macool host2passwd=marioandres`
    TariffDiff.new(args).run!
  end
end
