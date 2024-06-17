import { MapComponent } from '@hms.core.map.MapComponent'
import { geoLocationManager } from '@kit.LocationKit'
import { map, mapCommon, site } from "@kit.MapKit"
import { promptAction, router } from '@kit.ArkUI'
import { Card, CardItem, TopNavBar } from '@presenter/basic'

/*
 * !! 后续待补搜索位置
 *
 * */

@Entry
@Component
struct SelectLocation {
  @State
  list: SiteClass[] = []
  mapController: map.MapComponentController = new map.MapComponentController()

  async getLocation() {
    try {
      const rightResult = await geoLocationManager.getCurrentLocation()

      // 获取位置经纬WGS84
      // 花瓣地图 GCJ02
      // 地图上 将可相机挪动到具体的位置
      this.mapController.moveCamera(map.newCameraPosition({
        target: {
          longitude: rightResult.longitude,
          latitude: rightResult.latitude
        },
        zoom: 16
      }))
      // 添加一个标记
      this.mapController.addPointAnnotation({
        position: {
          longitude: rightResult.longitude,
          latitude: rightResult.latitude
        },
        titles: [{
          content: '您当前的位置'
        }]
      })
      // 周边搜索
      const res = await site.nearbySearch({
        location: {
          longitude: rightResult.longitude,
          latitude: rightResult.latitude
        },
        pageSize: 4,
        pageIndex: 1,
        radius: 50
      })
      this.list = res.sites?.slice(0, 4) as SiteClass[] // 只拿4条数据
    } catch (err) {
      promptAction.showToast({ message: '无法使用地图' })
    }
  }

  build() {
    Column() {
      TopNavBar({ title: '当前位置' })
      Stack({ alignContent: Alignment.Bottom }) {
        //  地图区域
        MapComponent({
          mapOptions: {
            position: {
              target: {
                latitude: 123.1,
                longitude: 113.3
              },
              zoom: 10
            }
          },
          mapCallback: (err, controller) => {
            if (!err) {
              this.mapController = controller
              this.getLocation() // 获取定位
            }
          }
        })
          .width('100%')
          .height('100%')
        Column() {
          Card() {
            ForEach(this.list, (item: SiteClass) => {
              CardItem({ leftTitle: item.name, rightText: `${item.distance}m` })
                .onClick(() => {
                  router.back({
                    url: "pages/Report/Report",
                    params: {
                      location: item.name
                    }
                  })
                })
            })


          }
        }
        .padding({
          bottom: 60
        })
      }
    }
    .padding({
      top: JSON.parse(AppStorage.get("topHeight")),
      bottom: JSON.parse(AppStorage.get('bottomHeight'))
    })
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}

class SiteClass {
  name: string = ""
  distance: number = 0
}