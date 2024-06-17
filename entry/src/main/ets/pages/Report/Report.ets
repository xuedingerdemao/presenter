import {
  Card,
  CardItem,
  checkPermission,
  CommonRouterParams,
  DateFormat,
  SelectCard,
  TopNavBar,
  Upload,
  UploadFile
} from '@presenter/basic'
import { promptAction, router } from '@kit.ArkUI'
import { ExceptionParamsType, ExceptionParamsTypeModel } from '../../models'
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit'
import { exceptionReportAPI } from '../../api/modules/taskAPI'

@Entry
@Component
struct Report {
  @State
  exceptionForm: ExceptionParamsTypeModel = new ExceptionParamsTypeModel({} as ExceptionParamsType)
  @State
  selectIndex: number = -1
  exceptionList: string[] = ["发动机启用困难", "不着车，漏油", "照明失灵", "有异常响动", "排烟异常温度异常", "其他问题"]
  // 选择类型的弹层
  selectDialog: CustomDialogController = new CustomDialogController({
    builder: SelectCard({
      cardContent: () => {
        // 必须调用一个builder的函数
        this.getCardContent()
      },
      confirm: () => {
        if (this.selectIndex > -1) {
          this.exceptionForm.exceptionType = this.exceptionList[this.selectIndex]
        }
        this.selectDialog.close()
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  @Builder
  getCardContent() {
    ForEach(this.exceptionList, (item: string, index: number) => {
      this.getSingleItem(item, index, index !== this.exceptionList.length - 1)
    })
  }

  @Builder
  getSingleItem(item: string, index: number, showBorder: boolean) {
    Row() {
      Text(item)
        .fontSize(14)
        .fontColor($r("app.color.text_primary"))
      Image(this.selectIndex === index ? $r("app.media.ic_check_true") : $r("app.media.ic_check_false"))
        .width(32)
        .height(32)
    }
    .onClick(() => {
      this.selectIndex = index // 赋值索引
    })
    .height(60)
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .border({
      color: $r("app.color.background_divider"),
      width: {
        bottom: showBorder ? 1 : 0
      }
    })
  }

  /*-----------------------👇👇 function 👇👇--------------------------------*/
  // aboutToAppear() {
  //   const params = router.getParams() as CommonRouterParams
  //   if (params && params.id) {
  //     this.exceptionForm.transportTaskId = params.id
  //   }
  // }
  onPageShow(): void {
    const params = router.getParams() as CommonRouterParams
    if (params && params.location) {
      this.exceptionForm.exceptionPlace = params.location
    }
    if (params && params.id) {
      this.exceptionForm.transportTaskId = params.id
    }
  }

  getBtnEnable() {
    return !!(this.exceptionForm.exceptionDescribe &&
    this.exceptionForm.exceptionPlace &&
    this.exceptionForm.exceptionType &&
    this.exceptionForm.exceptionTime)
  }

  async submit() {
    // 先上传 再调用接口
    if (this.exceptionForm.exceptionImagesList?.length) {
      // 云端地址
      this.exceptionForm.exceptionImagesList = await UploadFile(this.exceptionForm.exceptionImagesList)
    }
    // 调用接口
    await exceptionReportAPI(this.exceptionForm) // 上报异常
    promptAction.showToast({ message: '上报成功' })
    router.back({
      url: 'pages/TaskDetail/TaskDetail',
      params: {
        addExcept: true // 表示上报异常成功
      }
    })
  }

  /*请求权限方法*/
  // async checkPermission(requestPermission: Permissions[], permission: Permissions, mess: string, callback: () => void) {
  // /* [
  //        "ohos.permission.LOCATION",
  //        "ohos.permission.APPROXIMATELY_LOCATION"
  //      ]*/
  //   try {
  //     const manager = abilityAccessCtrl.createAtManager() // 创建程序控制管理器
  //     await manager.requestPermissionsFromUser(getContext(), requestPermission) //申请权限
  //     // 获取应用信息
  //     const buildInfo =
  //       bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
  //     const status = manager.checkAccessTokenSync(buildInfo.appInfo?.accessTokenId, permission)
  //     // promptAction.showDialog({ message: JSON.stringify(abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) })
  //     if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
  //       AlertDialog.show(
  //         {
  //           message: mess,
  //           autoCancel: true,
  //           alignment: DialogAlignment.Center,
  //           primaryButton: {
  //             value: '去申请',
  //             fontColor: Color.Black,
  //             action: () => {
  //               promptAction.showToast({ message: '确认' })
  //               // 不被允许
  //               const context = getContext() as common.UIAbilityContext
  //               context.startAbility({
  //                 bundleName: 'com.huawei.hmos.settings',
  //                 abilityName: 'com.huawei.hmos.settings.MainAbility',
  //                 uri: "application_info_entry",
  //                 parameters: {
  //                   pushParams: buildInfo.name
  //                 }
  //               })
  //             }
  //           },
  //           secondaryButton: {
  //             value: '取消申请',
  //             fontColor: Color.Red,
  //             action: () => {
  //               promptAction.showToast({ message: '取消' })
  //             }
  //           },
  //         })
  //     } else {
  //       callback && callback()
  //
  //     }
  //   } catch (error) {
  //
  //   }
  // }

  build() {
    Column() {
      TopNavBar({ title: '上报异常' })
      Scroll() {
        Column() {
          Card() {
            CardItem({
              leftTitle: '异常时间',
              rightText: this.exceptionForm.exceptionTime || '请选择',
              onRightClick: () => {
                DatePickerDialog.show({
                  showTime: true,
                  useMilitaryTime: true,
                  onDateAccept: (value) => {
                    this.exceptionForm.exceptionTime = DateFormat(value)
                  }
                })
              }
            })
            CardItem({
              leftTitle: '上报位置',
              rightText: '请选择',
              onRightClick: () => {
                const requestPermission: Permissions[] = [
                  "ohos.permission.LOCATION",
                  "ohos.permission.APPROXIMATELY_LOCATION"
                ]
                const permission: Permissions = 'ohos.permission.LOCATION'
                const mess = '使用定位需要申请定位风权限'

                const callback = () => {
                  router.pushUrl({
                    url: "pages/SelectLocation/SelectLocation"
                  })
                }

                checkPermission(requestPermission, permission, mess, () => {
                  callback()
                })

              }
            })
            CardItem({
              leftTitle: '异常类型',
              rightText: this.exceptionForm.exceptionType || '请选择',
              onRightClick: () => {
                this.selectDialog.open()
              }
            })
            CardItem({
              leftTitle: '异常描述',
              rightText: '',
              showRightIcon: false,
              showBottomBorder: false
            })
            TextArea({
              placeholder: '请输入异常描述'
            }).height(130).borderRadius(8).placeholderColor($r('app.color.text_secondary')).fontSize(14)
            Text(`0/50`)
              .margin({
                top: -30
              })
              .textAlign(TextAlign.End)
              .width('100%')
              .padding({ right: 15 })
              .fontColor($r('app.color.text_secondary'))
            Row().height(20)

          }

          Card() {
            Upload({
              title: '上传图片(最多6张)',
              imgList: this.exceptionForm.exceptionImagesList || [],
              canUpload: true,
              onListChange: (list) => {
                this.exceptionForm.exceptionImagesList = list // 接回传回的数组 相册地址 并不是线上地址
              }
            })
            Row().height(20)
          }
        }
      }.padding({
        bottom: 80
      })
      .layoutWeight(1)


      Row() {
        Button("提交")
          .height(50)
          .width(207)
          .backgroundColor($r('app.color.primary_disabled'))
          .enabled(this.getBtnEnable())
      }
      .position({
        y: '100%'
      })
      .height(70)
      .translate({
        y: -70
      })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.white'))
    }
    .padding({
      top: JSON.parse(AppStorage.get("topHeight")),
      bottom: JSON.parse(AppStorage.get('bottomHeight'))
    })
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}