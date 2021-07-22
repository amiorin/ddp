from apache_ranger.model.ranger_service     import RangerService
from apache_ranger.client.ranger_client     import RangerClient

ranger_client = RangerClient('http://ddp-ranger.example.com:6080', ('admin', 'ddpR0cks!'))

service = RangerService({'name': 'dev_atlas', 'type': 'atlas', 'configs': {'username':'atlas', 'password':'ddpR0cks!', 'atlas.rest.address': 'http://ddp-atlas.example.com:21000'}})

ranger_client.create_service(service)