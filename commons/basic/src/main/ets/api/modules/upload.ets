import request from '@ohos.request'
import { BASE_URL, USER_TOKEN_KEY } from '../../constants'
import { ImageList, ResponseData } from '../../models'

// 返回一个列表 ImageList[]
export const uploadImage = async (context: Context, files: request.File[]) => {
  let config: request.UploadConfig = {
    url: BASE_URL + '/files/imageUpload', // 拼接上传完整地址
    method: 'POST',
    header: {
      Authorization: AppStorage.get(USER_TOKEN_KEY) || "", // 应用中的token
      "Content-Type": "multipart/form-data" // 上传文件的参数类型
      // application/json  { name: '张三', age: 18 }
      // application/x-www-form-urlencoded 拼接   name=张三&age=18
      // text/xhtml 结构
      // multipart/form-data  专门传文件的结构
    },
    files,
    data: [] // 批量上传需要携带的参数 用不上
  }
  return new Promise<ImageList[]>(async (resolve, reject) => {
    try {
      let arr: ImageList[] = []
      const task = await request.uploadFile(context, config) // 成功执行并不意味着 上传成功 只是任务创建成功
      task.on("fail", () => {
        // 上传失败
        AlertDialog.show({
          message: "上传失败"
        })
        reject(new Error("上传失败"))
      })
      // 每上传成功一次就会进来
      task.on("headerReceive", (headers: object) => {
        if (headers["body"]) {
          const result = JSON.parse(headers["body"]) as ResponseData<string>
          if (result.code === 200) {
            arr.push({
              url: result.data as string
            })
          }
        }
      })
      task.on("complete", () => {
        // 上传完成
        // 也不能拿到上传成功的地址
        // 走到这里认为 要返回的结构已经ok了
        resolve(arr)
      })
    } catch (error) {
      AlertDialog.show({
        message: error.message // 提示错误消息
      })
      reject(error)
    }
  })

}