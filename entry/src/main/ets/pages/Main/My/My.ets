import { Card, CardItem, Skeleton } from '@presenter/basic'
import { getUserInfoAPI, getUserTaskInfoAPI } from '../../../api'
import { UserTaskInfo, UserTaskInfoModel, UserTaskInfoParamsModel } from '../../../models'
import { UserInfo, UserInfoModel } from '../../../models/modules/UserInfoModel'
import { router } from '@kit.ArkUI'

@Preview
@Component
export default struct My {
  @State
  userInfo: UserInfoModel = new UserInfoModel({} as UserInfo)
  @Consume
  @Watch('updateName')
  currentName: string
  @State
  userTaskInfo: UserTaskInfoModel = new UserTaskInfoModel({} as UserTaskInfo)
  queryTaskParams: UserTaskInfoParamsModel = new UserTaskInfoParamsModel({
    year: new Date().getFullYear().toString(),
    month: (new Date().getMonth() + 1).toString()
  })
  @State
  isLoading: boolean = false

  /*-----------------------👇👇 function 👇👇--------------------------------*/


  aboutToAppear(): void {
    this.getUserInfo()
  }

  /*  由于tab的子组件更新后，aboutToAppear只执行一次，无法在每次切换时更新最新数据
    所以使用下面方式在切换tab时进行刷新页面数据,任务数据可能会每次打开不一样(在不退出应用的情况下)*/
  async updateName() {
    if (this.currentName === 'my') {
      this.getUserTaskInfo()

    }
  }

  async getUserInfo() {
    this.userInfo = await getUserInfoAPI()

    this.isLoading = true
  }

  async getUserTaskInfo() {
    this.userTaskInfo = await getUserTaskInfoAPI(this.queryTaskParams)
  }

  build() {
    Column() {
      if (!this.userInfo.avatar) {
        Skeleton()
      } else {
        // 基本信息
        Column() {
          Image($r(this.userInfo.avatar ? this.userInfo.avatar : "app.media.ic_avatar_driver"))
            .width(67)
            .height(67)
            .borderRadius(34.5)
            .backgroundColor($r('app.color.white'))
          Text(this.userInfo.name)
            .fontSize(18)
            .fontWeight(600)
            .lineHeight(25)
            .margin({
              top: 9,
              bottom: 9
            })
            .fontColor($r('app.color.white'))
          Text(`司机编号: ${this.userInfo.number}`)
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(20)
            .fontColor($r('app.color.white'))
          Text(`手机号: ${this.userInfo.phone}`)
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(20)
            .margin({
              top: 10
            })
            .fontColor($r('app.color.white'))
        }
        .backgroundImage($r("app.media.bg_page_my"))
        .backgroundImageSize(ImageSize.Cover)
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .height(292)
        .margin({
          top: -2
        })

        // 本月任务
        Column() {
          Text("- 本月任务 -").fontSize(14).fontColor($r('app.color.text_secondary')).lineHeight(20)
          Row() {
            Column() {
              Text(this.userTaskInfo?.taskAmounts?.toString())
                .fontSize(18)
                .fontColor($r('app.color.text_primary'))
                .lineHeight(25)
                .margin({
                  bottom: 17
                })
              Text("任务总量").fontSize(12).fontColor($r('app.color.text_primary')).lineHeight(17)
            }.justifyContent(FlexAlign.SpaceAround).layoutWeight(1)

            Column() {
              Text(this.userTaskInfo?.completedAmounts?.toString())
                .fontSize(18)
                .fontColor($r('app.color.text_primary'))
                .lineHeight(25)
                .margin({ bottom: 17 })
              Text("完成任务量").fontSize(12).fontColor($r('app.color.text_primary')).lineHeight(17)
            }.justifyContent(FlexAlign.SpaceAround).layoutWeight(1)

            Column() {
              Text("1000")
                .fontSize(18)
                .fontColor($r('app.color.text_primary'))
                .lineHeight(25)
                .margin({ bottom: 17 })
              Text(this.userTaskInfo?.transportMileage?.toString())
                .fontSize(12)
                .fontColor($r('app.color.text_primary'))
                .lineHeight(17)
            }.justifyContent(FlexAlign.SpaceAround).layoutWeight(1)
          }.justifyContent(FlexAlign.SpaceBetween).width('100%').layoutWeight(1)
        }
        .backgroundColor($r('app.color.white'))
        .borderRadius(8)
        .margin({
          left: 14.5,
          right: 14.5,
          top: -55,
          bottom: 15
        })
        .height(134)
        .padding({ top: 13.5, bottom: 13.5 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 信息列表
        Card() {
          CardItem({ leftTitle: '车辆信息', rightText: '' })
          CardItem({ leftTitle: '任务设置', rightText: '' })
          CardItem({
            leftTitle: '系统设置',
            rightText: '',
            showBottomBorder: false,
            onRightClick: () => {
              router.pushUrl({
                url: 'pages/Main/Setting/Setting'
              })
            }
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
    .borderRadius(8)
  }
}

