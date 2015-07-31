# Trade Tariff API Testing

## Tariff

### `chapters_diff`
Use `tariff:chapters_diff` task to compare chapters, headings and commodities between two API endpoints.

examples:
```
bundle exec rake tariff:chapters_diff[host1,host2]
bundle exec rake tariff:chapters_diff[http://162.13.179.183:3018/,http://10.1.1.254:3018/]
```

### `updates_diff`
Use `tariff:updates_diff` task to compare updates between two endpoints.

examples:
```
bundle exec rake tariff:updates_diff[host1,host2]
bundle exec rake tariff:updates_diff[http://tariff.dev.gov.uk:3018/,https://www.gov.uk/trade-tariff]
```
