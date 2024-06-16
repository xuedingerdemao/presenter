import { fileIo, picker } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { request } from '@kit.BasicServicesKit'
import { PreviewImg } from '..'
import { ImageList } from '../../models'
import { uploadImage } from '../../api/modules/upload'

// 上传的组件 并不完成上传的业务 选择图片 用来交互的
@Preview
@Component
struct Upload {
  @Prop
  canUpload: boolean = true // 是否可操作可上传
  title: string = "" // 作为标题
  maxNumber: number = 3 // 最大选择数量
  @Prop // Next版本可以传入任何类型
  imgList: ImageList[] = [] // 提交接口
  index: number = -1
  // 当列表发生变化 通知父组件改变
  onListChange: (list: ImageList[]) => void = () => {
  }
  preview: CustomDialogController = new CustomDialogController({
    builder: PreviewImg({
      urls: this.imgList.map(item => item.url),
      selectIndex: this.index
    }),
    customStyle: true, // 自定义样式
  })

  async selectImg() {
    const photo = new picker.PhotoViewPicker() // 图片选择对象
    const result = await photo.select({
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: this.maxNumber - this.imgList.length // 还剩多少张可以选
    })
    if (result.photoUris.length) {
      // 追加操作
      this.imgList = this.imgList.concat(result.photoUris.map(url => ({
        url
      } as ImageList)))
      this.onListChange(this.imgList) // 通知父组件更新
    }
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(14)
        .fontColor($r("app.color.text_secondary"))
        .margin({
          top: 16,
          bottom: 16
        })
      Grid() {
        ForEach(this.imgList, (item: ImageList, index: number) => {
          GridItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item.url)
                .width(100)
                .height(100)
                .borderRadius(4)
                .onClick(() => {
                  this.index = index // 要看第几张图片
                  this.preview.open() // 打开弹层
                })
              if (this.canUpload) {
                Image($r("app.media.ic_btn_delete"))
                  .width(30)
                  .height(30)
                  .onClick(() => {
                    this.imgList.splice(index, 1) // 移除索引
                    this.onListChange(this.imgList) // 通知父组件更新
                  })
              }

            }

          }
        })
        // 显示上传 还没有达到最满情况下 可以显示 上传按钮
        if (this.imgList.length < this.maxNumber && this.canUpload) {
          GridItem() {
            Row() {
              Image($r("app.media.ic_add_img"))
                .width(30)
                .height(30)
            }
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r("app.color.background_page"))
            .width(100)
            .height(100)
            .borderRadius(4)
            .onClick(() => {
              this.selectImg()
            })
          }

        }
      }
      .height(Math.ceil(this.maxNumber / 3) * 110)
      .rowsGap(10) // 行间距
      .columnsGap(10) // 列间距
      .columnsTemplate("1fr 1fr 1fr")

    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
  }
}

// 上传方法
const UploadFile = async (list: ImageList[]) => {
  // 因为上传文件只能从沙箱文件中拷贝所以 我们需要把传过来的所有的图片拷贝到沙箱
  const saveDir = getContext().cacheDir // 存储的目录
  const fileParams: request.File[] = [] // 要提交的参数
  list.forEach(item => {
    const file = fileIo.openSync(item.url, fileIo.OpenMode.READ_ONLY) // 读取相册的文件
    // 将文件拷贝到沙箱目录
    // 相册的地址
    const uniqueName = util.generateRandomUUID() + ".jpg"
    fileIo.copyFileSync(file.fd, saveDir + "/" + uniqueName) // 将相册文件拷贝到沙箱
    // 需要生成参数
    fileParams.push({
      filename: uniqueName, // 文件名称
      name: 'file', // 接口的参数名称
      type: 'jpg', // 文件后缀
      uri: `internal://cache/${uniqueName}` // 应该是文件放到cache目录下 如果是cache协议 它会自动找这个文件
    })
    fileIo.closeSync(file.fd)
  })
  // 将参数进行上传
  return await uploadImage(getContext(), fileParams) // 调用上传接口 // 将上传的结果再返回上一层
}

export { Upload, UploadFile }