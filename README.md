# Trade Tariff API Testing

## Tariff

### `chapters_diff`
Use `tariff:chapters_diff` task to compare chapters, headings and commodities between two API endpoints.

examples:
```
bundle exec rake tariff:chapters_diff[host1,host2]
bundle exec rake tariff:chapters_diff[https://www.gov.uk/trade-tariff, https://tariff-frontend-dev.cloudapps.digital/trade-tariff]
```

### `updates_diff`
Use `tariff:updates_diff` task to compare updates between two endpoints.

examples:
```
bundle exec rake tariff:updates_diff[host1,host2]
bundle exec rake tariff:updates_diff[https://www.gov.uk/trade-tariff, https://tariff-frontend-dev.cloudapps.digital/trade-tariff]
```
