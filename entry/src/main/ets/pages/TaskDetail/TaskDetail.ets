import { componentSnapshot, promptAction, router } from '@kit.ArkUI'
import {
  DeliverParamsTypeModel,
  ExceptionList,
  PickUpParamsModel,
  TaskDetailInfo,
  TaskDetailInfoModel,
  TaskTypeEnum
} from '../../models'
import {
  CommonRouterParams,
  ImageList,
  Loading,
  Skeleton,
  ToggleCard,
  TopNavBar,
  Upload,
  UploadFile
} from '@presenter/basic'
import { deliverAPI, getTaskDetailAPI, pickUpAPI } from '../../api/modules/taskAPI'
import { common } from '@kit.AbilityKit'
import { call } from '@kit.TelephonyKit'
import { MessageEvents, worker } from '@kit.ArkTS'
import { PostParams } from '../../workers/UploadWorker'
import { image } from '@kit.ImageKit'

class BaseBuilderClass {
  title: string = ""
  value: string = ""
  icon?: ResourceStr = ""
  iconClick?: () => void
}

@Extend(Text)
function baseTextOneStyle() {
  .fontSize(12)
  .fontColor($r('app.color.white'))
  .backgroundColor($r('app.color.text_primary'))
  .width(22)
  .height(22)
  .borderRadius(11)
  .textAlign(TextAlign.Center)
}

@Extend(Text)
function baseTextTwoStyle() {
  .margin({ left: 11.5 }).fontColor($r('app.color.text_secondary')).fontSize(14).lineHeight(20)
}

@Entry
@Component
struct TaskDetail {
  @State
  taskDetailData: TaskDetailInfoModel = new TaskDetailInfoModel({} as TaskDetailInfo)
  scroller: Scroller = new Scroller() // 滚动
  loading: CustomDialogController = new CustomDialogController({
    builder: Loading({ title: '处理中...' }),
    customStyle: true
  })
  @State
  snapImg: image.PixelMap | null = null
  @State
  showSnap: boolean = false

  /*-----------------------👇👇 Builder 👇👇--------------------------------*/
  // 司机信息
  @Builder
  getDriverContent() {
    Row() {
      Text("车牌号").fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Text(this.taskDetailData.licensePlate).fontSize(14).fontColor($r('app.color.text_secondary'))
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })

    Row() {
      Text(`司机姓名`).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Text(this.taskDetailData.driverName).fontSize(14).fontColor($r('app.color.text_secondary'))
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }

  // 运输路线
  @Builder
  getTransLineContent() {
    Row() {
      Column() {
        Text(this.taskDetailData.startProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskDetailData.startCity).fontSize(14).lineHeight(22)
      }.width(50)

      Image($r("app.media.ic_right_arrow")).width(36).height(16)
      Column() {
        Text(this.taskDetailData.endProvince)
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(22)
          .fontWeight(600)
        Text(this.taskDetailData.endCity).fontSize(14).lineHeight(22)
      }.width(50)
    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%').padding({
      left: 60,
      right: 60
    })
  }

  @Builder
  getBaseContentItem(item: BaseBuilderClass) {
    Row() {
      Text(item.title).fontSize(14).fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
      Row() {
        Text(item.value).fontSize(14).fontColor($r('app.color.text_secondary'))
        if (item.icon) {
          Image(item.icon).width(24).height(24)
            .onClick(() => {
              item.iconClick && item.iconClick()
            })
        }
      }
    }.justifyContent(FlexAlign.SpaceBetween).width('100%').margin({
      top: 14
    })
  }

  // 获取基础信息
  @Builder
  getBaseContent() {
    Row() {
      Column() {
        Row() {
          Text("起").baseTextOneStyle()
          Text("地址地址").baseTextTwoStyle()
        }.margin({ top: 21 })

        Row() {
          Text("止").baseTextOneStyle().backgroundColor($r('app.color.primary'))
          Text("河南省郑州市路北区北清路99号").baseTextTwoStyle()
        }.margin({ top: 14.5 })
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({
        right: 20
      })

      // 送货过程中才显示导航
      if (this.taskDetailData.status === TaskTypeEnum.Line) {
        Column() {
          Image($r("app.media.ic_navigation")).width(22).height(22)
          Text("开始导航").fontSize(14).margin({ top: 10, bottom: 10 })
        }.justifyContent(FlexAlign.SpaceBetween)
        .margin({
          top: 20
        })
        .onClick(() => {
          // 开启导航
          this.beginNav()
        })
      }

    }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%')

    Divider().vertical(false).height(2).color($r('app.color.background_divider')).margin({ left: 8, right: 8, top: 21 })
    this.getBaseContentItem({
      title: '任务编号',
      value: '2132324324343434'
    })
    this.getBaseContentItem({
      title: '联系人',
      value: '2132324324343434',
      iconClick: () => {
        call.makeCall(this.taskDetailData.startHandoverPhone)
      }
    })
    this.getBaseContentItem({
      title: '联系电话',
      value: '2132324324343434',
      icon: $r('app.media.ic_phone')
    })
    this.getBaseContentItem({
      title: '提货时间',
      value: '2132324324343434'
    })
    this.getBaseContentItem({
      title: '预计送达时间',
      value: '2132324324343434'
    })

  }

  // 底部按钮结构
  @Builder
  getBottomBtn() {
    //已完成不显示任何按钮
    Row() {
      if (this.taskDetailData.status === TaskTypeEnum.Waiting) {
        Button("延迟收货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.btn_gray'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(16)
          .height(50)
          .width(125)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DelayPage/DelayPage',
              params: {
                id: this.taskDetailData.id,
                oldTime: this.taskDetailData.planDepartureTime // 计划时间
              }
            })
          })
        Button("提货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.white'))
          .height(50)
          .flexGrow(1)
          .margin({ left: 13 })
          .enabled(this.getPickUpState())
          .onClick(() => {
            this.btnPickUp()
          })
      } else if (this.taskDetailData.status === TaskTypeEnum.Line) {
        Button("上报异常", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.btn_gray'))
          .fontColor($r('app.color.text_primary'))
          .fontSize(16)
          .height(50)
          .width(125)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Report/Report',
              params: {
                id: this.taskDetailData.transportTaskId // id并不是订单的id 而是transportTaskId
              }
            })
          })
        Button("交货", { type: ButtonType.Capsule })
          .backgroundColor($r('app.color.primary'))
          .fontColor($r('app.color.white'))
          .height(50)
          .flexGrow(1)
          .enabled(this.getDeliverState())
          .margin({ left: 13 })
          .onClick(() => {
            this.btnDeliver()
          })

      } else if (this.taskDetailData.status === TaskTypeEnum.Delivered) {
        Row() {
          // 已交付显示回车登记
          Button("回车登记", { type: ButtonType.Capsule })
            .backgroundColor($r('app.color.primary'))
            .fontColor($r('app.color.white'))
            .height(50)
            .width('80%')
            .onClick(() => {
              router.pushUrl({
                url: 'pages/CarRecord/CarRecord',
                params: {
                  id: this.taskDetailData.id,
                  // time: this.taskDetailData.actualDepartureTime
                }
              })
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }

    }
    .width('100%')
    .padding({ left: 15, right: 15 })
    .height(70)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('app.color.white'))
  }

  // 提货信息内容
  @Builder
  getPickUpContent() {
    // @Link修饰符 修饰只能是一层数据
    Upload({
      title: '请拍照上传回单凭证',
      imgList: this.taskDetailData.cargoPickUpPictureList || [], // 父组件给子组件传
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.cargoPickUpPictureList = list // 子组件给父组件传
      },
      canUpload: this.taskDetailData.status === TaskTypeEnum.Waiting
    })
    Upload({
      title: '请拍照上传货品照片',
      imgList: this.taskDetailData.cargoPictureList || [],
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.cargoPictureList = list
      },
      canUpload: this.taskDetailData.status === TaskTypeEnum.Waiting

    })
  }

  // 交货信息
  @Builder
  getDeliverContent() {
    // @Link修饰符 修饰只能是一层数据
    Upload({
      title: '请拍照上传交货回单凭证',
      imgList: this.taskDetailData.certificatePictureList || [], // 父组件给子组件传
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.certificatePictureList = list // 子组件给父组件传
      },
      canUpload: this.taskDetailData.status === TaskTypeEnum.Line

    })
    Upload({
      title: '请拍照上传交货货品照片',
      imgList: this.taskDetailData.deliverPictureList || [],
      onListChange: (list: ImageList[]) => {
        this.taskDetailData.deliverPictureList = list
      },
      canUpload: this.taskDetailData.status === TaskTypeEnum.Line
    })
  }

  // 获取异常信息
  @Builder
  getExceptionContent() {
    ForEach(this.taskDetailData.exceptionList, (item: ExceptionList) => {
      Row() {
        Column() {
          Row() {
            Text("上报时间").fontSize(14).fontColor($r('app.color.text_primary'))
            Text(item.exceptionTime).margin({ left: 20 }).fontColor($r('app.color.text_secondary'))
          }.height(50).alignItems(VerticalAlign.Center).width('100%')

          Row() {
            Text("异常类型").fontSize(14).fontColor($r('app.color.text_primary'))
            Text(item.exceptionType).margin({ left: 20 }).fontColor($r('app.color.text_secondary'))
          }.height(50).alignItems(VerticalAlign.Center).width('100%')

          Row() {
            Text("处理结果").fontSize(14).fontColor($r('app.color.text_primary'))
            Text("继续运输").margin({ left: 20 }).fontColor($r('app.color.text_secondary'))
          }.height(50).alignItems(VerticalAlign.Center).width('100%')
        }

        // 跳转到详情
        Image($r("app.media.ic_btn_more")).width(24).height(24)
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        router.pushUrl({
          url: 'pages/Report/ReportDetail',
          params: {
            formData: item
          }
        })
      })

    })
  }

  @Builder
  getSnapContent() {
    Column() {
      Image(this.snapImg)
        .width("100%")
        .height("100%")
        .objectFit(ImageFit.Auto)
        .borderRadius(6)
    }
    .padding("10%")
    .width("100%")
    .height("100%")
    .backgroundColor("rgba(0,0,0,0.2)")
    .onClick(() => {
      this.showSnap = false
    })
  }

  /*-----------------------👇👇 function 👇👇--------------------------------*/
  aboutToAppear() {
    const params = router.getParams() as CommonRouterParams
    if (params && params.id) {
      this.getTaskDetail(params.id)
    }
  }

  onPageShow(): void {
    const params = router.getParams() as CommonRouterParams
    if (params && params.addExcept) {
      // 此时需要更新异常信息 其他信息不更新
      this.updateException()
    }
  }

  async updateException() {
    // 只更新异常信息的字段
    this.taskDetailData.exceptionList = (await getTaskDetailAPI(this.taskDetailData.id)).exceptionList
  }

  async getTaskDetail(id: string) {
    this.taskDetailData = await getTaskDetailAPI(id)
  }

  // 去提货
  async btnPickUp() {
    this.loading.open()
    // 建立子线程
    const imageCompress1 = new worker.ThreadWorker("entry/ets/workers/UploadWorker.ets") // 子线程1
    const imageCompress2 = new worker.ThreadWorker("entry/ets/workers/UploadWorker.ets") // 子线程2
    let cargoPickUpPictureList: ImageList[] = []
    let cargoPictureList: ImageList[] = []

    imageCompress1.onmessage = (e: MessageEvents) => {
      const params = e.data as PostParams
      cargoPickUpPictureList = params.files // 已经压缩完毕的图片
      checkFile() // 检查是否都完成了
    }
    imageCompress2.onmessage = (e: MessageEvents) => {
      const params = e.data as PostParams
      cargoPictureList = params.files // 已经压缩完毕的图片
      checkFile()
    }
    imageCompress1.postMessage({
      files: [...this.taskDetailData.cargoPickUpPictureList],
      filePath: getContext().filesDir
    }) // 给子线程发消息
    imageCompress2.postMessage({
      files: [...this.taskDetailData.cargoPictureList],
      filePath: getContext().filesDir
    }) // 给子线程发消息

    const checkFile = async () => {
      if (cargoPickUpPictureList.length && cargoPictureList.length) {
        const result = await Promise.all([UploadFile(cargoPickUpPictureList), UploadFile(cargoPictureList)])
        // 提货操作
        await pickUpAPI(new PickUpParamsModel({
          id: this.taskDetailData.id,
          cargoPickUpPictureList: result[0],
          cargoPictureList: result[1]
        }))
        this.getTaskDetail(this.taskDetailData.id) // 重新拉取数据
        this.scroller.scrollEdge(Edge.Top)
        this.loading.close()
        promptAction.showToast({ message: '提货成功' })
      }
    }


  }

  // 获取提货按钮的状态
  getPickUpState() {
    return this.taskDetailData.cargoPickUpPictureList?.length > 0 &&
      this.taskDetailData.cargoPictureList?.length > 0 &&
    this.taskDetailData.cargoPickUpPictureList.every(item =>!!item.url) &&
    this.taskDetailData.cargoPictureList.every(item =>!!item.url)
  }

  // 控制提货按钮可用性
  getDeliverState() {
    // 可用 凭证有图片 货品有图片 就可以点提货
    if (this.taskDetailData.deliverPictureList?.length
      && this.taskDetailData.deliverPictureList?.every(item =>!!item.url)
      && this.taskDetailData.certificatePictureList?.length
      && this.taskDetailData.certificatePictureList?.every(item =>!!item.url)) {
      return true
    }
    return false
  }

  // 交货
  async btnDeliver() {
    this.loading.open()
    // 建立子线程
    const imageCompress1 = new worker.ThreadWorker("entry/ets/workers/UploadWorker.ets") // 子线程1
    const imageCompress2 = new worker.ThreadWorker("entry/ets/workers/UploadWorker.ets") // 子线程2
    let certificatePictureList: ImageList[] = []
    let deliverPictureList: ImageList[] = []
    imageCompress1.onmessage = (e: MessageEvents) => {
      const params = e.data as PostParams
      certificatePictureList = params.files // 已经压缩完毕的图片
      checkFile() // 检查是否都完成了
    }
    imageCompress2.onmessage = (e: MessageEvents) => {
      const params = e.data as PostParams
      deliverPictureList = params.files // 已经压缩完毕的图片
      checkFile()
    }
    imageCompress1.postMessage({
      files: [...this.taskDetailData.certificatePictureList],
      filePath: getContext().filesDir
    }) // 给子线程发消息
    imageCompress2.postMessage({
      files: [...this.taskDetailData.deliverPictureList],
      filePath: getContext().filesDir
    }) // 给子线程发消息
    // 用来检查是否全部都压缩完毕
    const checkFile = async () => {
      if (certificatePictureList.length && deliverPictureList.length) {
        // 此时此刻才可以进行下一步操作
        const result = await Promise.all([UploadFile(certificatePictureList), UploadFile(deliverPictureList)])
        await deliverAPI(new DeliverParamsTypeModel({
          id: this.taskDetailData.id,
          certificatePictureList: result[0],
          deliverPictureList: result[1]
        }))
        this.getTaskDetail(this.taskDetailData.id) // 重新拉取数据
        this.scroller.scrollEdge(Edge.Top)
        promptAction.showToast({ message: '交货成功' })
        this.loading.close()
      }
    }
  }

  // 导航  拉起第三方的应用
  beginNav() {
    const context = getContext() as common.UIAbilityContext
    context.startAbility({
      action: 'ohos.want.action.viewData', // 拉起浏览器应用
      entities: ['entity.system.browsable'],
      uri: encodeURI('https://gaode.com/search?query=' + this.taskDetailData.endAddress)
    })
  }

  build() {
    Column() {
      if (!this.taskDetailData.id) {
        Skeleton()
      } else {

        TopNavBar({ title: '任务详情' })
        Scroll(this.scroller) {
          Column() {
            Row() {
              Image($r("app.media.share"))
                .width(20)
                .height(20)
                .fillColor($r("app.color.primary"))
                .onClick(async () => {
                  this.snapImg = await componentSnapshot.get("CutImg")
                  this.showSnap = true
                  // const res = getInspectorByKey("CutImg")
                })
            }
            .width("100%")
            .justifyContent(FlexAlign.End)
            .padding(10)

            ToggleCard({ title: '基本信息' }) {
              this.getBaseContent()
            }

            ToggleCard({ title: '车辆司机信息' }) {
              this.getDriverContent()
            }

            ToggleCard({ title: '运输路线' }) {
              this.getTransLineContent()
            }

            if (this.taskDetailData.status === TaskTypeEnum.Waiting
              || this.taskDetailData.status === TaskTypeEnum.Delivered
              || this.taskDetailData.status === TaskTypeEnum.Finish
            ) {
              ToggleCard({ title: '提货信息' }) {
                this.getPickUpContent()
              }
            }
            if (this.taskDetailData.status === TaskTypeEnum.Line
              || this.taskDetailData.status === TaskTypeEnum.Delivered
              || this.taskDetailData.status === TaskTypeEnum.Finish
            ) {
              ToggleCard({ title: '交货信息' }) {
                // 上传组件 基础组件
                this.getDeliverContent()
              }
            }
          }
          .padding({
            bottom: 10
          })
          .layoutWeight(1)
        }
        .margin({ bottom: 10 })
        .layoutWeight(1)

        this.getBottomBtn() // 底部按钮结构
      }
    }
    .padding({
      top: JSON.parse(AppStorage.get("topHeight")),
      bottom: JSON.parse(AppStorage.get('bottomHeight'))
    })
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
    .id('CutImg')
    .bindContentCover($$this.showSnap, this.getSnapContent(), {
      modalTransition: ModalTransition.NONE
    })
  }
}
