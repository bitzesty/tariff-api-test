# Trade Tariff API Testing

## Tariff

### `diff`
Use `tariff:diff` task to compare two API endpoints.

examples:
```
bundle exec rake tariff:diff[host1,host2]
bundle exec rake tariff:diff[http://162.13.179.183:3018/,http://10.1.1.254:3018/]
```
