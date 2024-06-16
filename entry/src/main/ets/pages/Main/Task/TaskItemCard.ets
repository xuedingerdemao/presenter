import { TaskInfoItem, TaskInfoItemModel, TaskTypeEnum } from '../../../models'
import { router } from '@kit.ArkUI'

@Preview
@Component
struct TaskItemCard {
  // taskItemData: Partial<TaskInfoItem>  = {}
  taskItemData: TaskInfoItemModel = new TaskInfoItemModel({} as TaskInfoItem)

  // 获取提货按钮是否可用
  getBtnEnable() {
    // 提货的时候可以点按钮
    if (this.taskItemData.enablePickUp) {
      return true
    }
    // 判断当然的状态
    // 交货或者回车登记的时候可点按钮
    switch (this.taskItemData.status.toString()) {
      case TaskTypeEnum.Line.toString():
        return true
      case TaskTypeEnum.Delivered.toString():
        return true
      default:
        return false
    }
  }

  // 去提货
  toPickUp() {
    router.pushUrl({
      url: 'pages/TaskDetail/TaskDetail',
      params: {
        id: this.taskItemData.id
      }
    })
  }

  // 获取按钮显示的文本
  getBtnText() {
    // 虽然类型为string 但是实际值是number
    switch (this.taskItemData.status.toString()) {
      case TaskTypeEnum.Waiting.toString():
        return "提货"
      case TaskTypeEnum.Line.toString():
        return "交货"
      case TaskTypeEnum.Delivered.toString():
        return "回车登记"
      default:
        return ""
    }
  }

  build() {
    Column() {
      Row() {
        Text(`任务编号：${this.taskItemData.transportTaskId}`)
          .fontSize(16)
          .fontColor($r("app.color.text_primary"))
          .fontWeight(500)
          .lineHeight(22)
      }.justifyContent(FlexAlign.SpaceBetween).width('100%')

      Row() {
        Text("起")
          .fontSize(12)
          .fontColor($r("app.color.white"))
          .backgroundColor($r("app.color.text_primary"))
          .width(22)
          .height(22)
          .borderRadius(11)
          .textAlign(TextAlign.Center)
        Text(this.taskItemData.startAddress)
          .margin({ left: 11.5 })
          .fontColor($r('app.color.text_secondary'))
          .fontSize(14)
      }.margin({ top: 21 }).width('100%')

      Row() {
        Text("止")
          .fontSize(12)
          .fontColor($r("app.color.white"))
          .backgroundColor($r('app.color.primary'))
          .width(22)
          .height(22)
          .borderRadius(11)
          .textAlign(TextAlign.Center)
        Text(this.taskItemData.endAddress)
          .margin({ left: 11.5 })
          .fontColor($r('app.color.text_secondary'))
          .fontSize(14)
      }.margin({ top: 14.5 }).width('100%')

      Divider()
        .vertical(true)
        .height(2)
        .color($r('app.color.background_divider'))
        .opacity(0.6)
        .margin({ left: 8, right: 8, top: 21 })
      Row() {
        Column() {
          Text('提货时间').fontSize(14).fontColor($r('app.color.text_secondary'))
          Text(this.taskItemData.planDepartureTime)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)

        // ts 的类型其实是鸭子 结构类型
        // 名字可以不一样 但是结构一样也能匹配类型
        if (parseInt(this.taskItemData.status) !== TaskTypeEnum.Finish) {
          Button(this.getBtnText(), { type: ButtonType.Capsule })
            .backgroundColor($r('app.color.primary'))
            .fontColor($r("app.color.white"))
            .fontSize(14)
            .height(32)
            .enabled(this.getBtnEnable())
            .onClick(() => {
              this.toPickUp()
            })
        }


      }.justifyContent(FlexAlign.SpaceBetween).width('100%')
    }
    .margin({ left: 15, right: 15, top: 15 })
    .padding({
      left: 19.5,
      right: 19.5,
      bottom: 18.5,
      top: 18.5
    })
    .borderRadius(10)
    .backgroundColor($r('app.color.white'))
    .onClick(() => {
      if (parseInt(this.taskItemData.status) === TaskTypeEnum.Finish) {
        this.toPickUp() // 已完成情况下 点击卡片可以进去看详情
      }
    })

  }
}

export default TaskItemCard