import { Card, CardItem, CheckBox, CommonRouterParams, DateFormat, Loading, TopNavBar } from '@presenter/basic'
import {
  CarRecordType,
  CarRecordTypeModel,
  TaskDetailInfo,
  TaskDetailInfoModel
} from '../../models'
import { promptAction, router } from '@kit.ArkUI'
import { carRecordAPI, getTaskDetailAPI } from '../../api/modules/taskAPI'

@Entry
@Component
struct CarRecord {
  @State
  taskDetailData: TaskDetailInfoModel = new TaskDetailInfoModel({} as TaskDetailInfo)
  @State
  carRecord: CarRecordTypeModel = new CarRecordTypeModel({} as CarRecordType)
  loading: CustomDialogController = new CustomDialogController({
    builder: Loading({ title: '提交中...' }),
    customStyle: true
  })

  /*-----------------------👇👇 function 👇👇--------------------------------*/

  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.getTaskDetail(params.id)
    }
  }

  async getTaskDetail(id: string) {
    this.taskDetailData = await getTaskDetailAPI(id)
  }

  // 检查再提交
  async btnCarRecord() {
    if (!this.carRecord.endTime) {
      promptAction.showToast({ message: '请选择回车时间' })
      return
    }
    this.carRecord.startTime = this.taskDetailData.actualDepartureTime
    // 运输任务id
    this.carRecord.id = this.taskDetailData.transportTaskId
    this.loading.open()
    await carRecordAPI(this.carRecord)
    this.loading.close()
    promptAction.showToast({ message: '回车登记成功' })
    router.clear() // 清空页面栈
    router.replaceUrl({ url: 'pages/Main/Index' })
  }

  build() {
    Column() {
      TopNavBar({ title: '回车登记' })
      Scroll() {
        Column() {
          Card() {
            CardItem({
              leftTitle: '出车时间',
              showRightIcon: false,
              rightText: this.taskDetailData.actualDepartureTime || '',
            })
            CardItem({
              leftTitle: '回车时间',
              rightText: this.carRecord.endTime || '请选择',
              showBottomBorder: false,
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true,
                  onDateAccept: (value: Date) => {
                    this.carRecord.endTime = DateFormat(value)
                  }
                })
              }

            })
          }

          CheckBox({
            title: '车辆违章',
            value: !!this.carRecord.isBreakRules,
            checkChange: (value) => {
              this.carRecord.isBreakRules = value
            }
          })
          CheckBox({
            title: '车辆故障',
            value: !!this.carRecord.isFault,
            checkChange: (value) => {
              this.carRecord.isFault = value
            }
          })
          CheckBox({
            title: '车辆事故',
            value: !!this.carRecord.isAccident,
            checkChange: (value) => {
              this.carRecord.isAccident = value
            }
          })
        }
        .height('100%')
      }
      .layoutWeight(1)

      // 底部内容
      Row() {
        Button("交车", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .width(207)
          .height(50)
          .onClick(() => {
            this.btnCarRecord()
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .padding({
        top: JSON.parse(AppStorage.get('bottomHeight')),
        bottom: JSON.parse(AppStorage.get('bottomHeight')) + 20
      })
      .width('100%')
      .height(70)
      .backgroundColor($r('app.color.white'))
    }
    .padding({
      top: JSON.parse(AppStorage.get("topHeight")),

    })
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}