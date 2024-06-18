import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, util, worker } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { ImageList } from '@presenter/basic';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

export class PostParams {
  files: ImageList[] = []
  filePath: string = "" // 沙箱目录
}

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessage = async (e: MessageEvents) => {
  // 处理耗时任务e
  const params = e.data as PostParams
  // 进行图片压缩
  if (params && params.files) {
    // 拿到原图
    // 对原图进行压缩
    // 需要将原图压缩成新的图片 存到一个位置
    const imagePackerAPI = image.createImagePacker() // 创建图片压缩API
    let packOpts: image.PackingOption = { format: "image/jpeg", quality: 20 };
    let arr: ImageList[] = []
    while (params.files.length) {
      const obj = params.files.pop() // 每次取一条
      const sourceFile = fileIo.openSync(obj?.url, fileIo.OpenMode.READ_ONLY) // 打开来源文件
      // 对来源文件进行压缩
      const newFileName = params.filePath + "/" + util.generateRandomUUID() + ".jpg"
      const targetFile = fileIo.openSync(newFileName, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      // 目标文件的fd
      await imagePackerAPI.packToFile(image.createImageSource(sourceFile.fd), targetFile.fd, packOpts)
      fileIo.closeSync(sourceFile.fd) // 关闭来源文件
      fileIo.closeSync(targetFile.fd) // 关闭目标文件
      arr.push({
        url: newFileName
      })
    }
    // 图片压缩完毕 将图片传出去
    workerPort.postMessage({ files: arr }) // 子线程往主线程发消息
    workerPort.close() // 结束子线程

  }


}

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessageerror = (e: MessageEvents) => {
}

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param e error message
 */
workerPort.onerror = (e: ErrorEvent) => {
}