import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'

/*
 * 请求权限封装抽离
 * */
const checkPermission =
  async (requestPermission: Permissions[], permission: Permissions, mess: string, callback: () => void) => {
    try {
      const manager = abilityAccessCtrl.createAtManager() // 创建程序控制管理器
      const res = await manager.requestPermissionsFromUser(getContext(), requestPermission) //申请权限
      if (res.dialogShownResults?.every(item => item)) {
        return
      }
      // 获取应用信息
      const buildInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      const status = manager.checkAccessTokenSync(buildInfo.appInfo?.accessTokenId, permission)
      // promptAction.showDialog({ message: JSON.stringify(abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) })
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        AlertDialog.show(
          {
            message: mess,
            autoCancel: true,
            alignment: DialogAlignment.Center,
            primaryButton: {
              value: '去申请',
              fontColor: Color.Black,
              action: () => {
                promptAction.showToast({ message: '确认' })
                // 不被允许
                const context = getContext() as common.UIAbilityContext
                context.startAbility({
                  bundleName: 'com.huawei.hmos.settings',
                  abilityName: 'com.huawei.hmos.settings.MainAbility',
                  uri: "application_info_entry",
                  parameters: {
                    pushParams: buildInfo.name
                  }
                })
              }
            },
            secondaryButton: {
              value: '取消申请',
              fontColor: Color.Red,
              action: () => {
                promptAction.showToast({ message: '取消' })
              }
            },
          })
      } else {
        callback && callback()

      }
    } catch (error) {

    }
  }


export { checkPermission }