from apache_ranger.model.ranger_service     import RangerService
from apache_ranger.client.ranger_client     import RangerClient

ranger_client = RangerClient('http://ddp-ranger.example.com:6080', ('admin', 'ddpR0cks!'))

service = RangerService({'name': 'starburst-enterprise', 'type': 'starburst-enterprise', 'configs': {'username':'ddp', 'jdbc.driverClassName': 'io.trino.jdbc.TrinoDriver', 'jdbc.url': 'jdbc:trino://ddp-starburst.example.com:8080'}})

ranger_client.create_service(service)