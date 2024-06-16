import { TaskInfoItem, TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItemCard'
import { ListComponents, Loading } from '@presenter/basic'
import { getTaskListAPI } from '../../../api/modules/taskAPI'

// 待提货
@Component
struct TaskList {
  loading: CustomDialogController = new CustomDialogController({
    builder: Loading(),
    customStyle: true
  })
  @State
  queryParams: TaskListParamsModel = new TaskListParamsModel(
    {
      status: TaskTypeEnum.Waiting, // 待提货的类型
      page: 1, // 第几页
      pageSize: 5 // 每页几条数据
    } as TaskListParams
  )
  @State
  taskListData: TaskInfoItem[] = []
  @State
  allPage: number = 1 // 默认只有一页
  @State
  reset: boolean = false // 用来控制重置状态

  async getTaskList(append: boolean) {
    const result = await getTaskListAPI(this.queryParams)
    // 追加数据
    // this.taskListData = this.taskListData.concat(result.items) // 拿到返回的数组
    if (append) {
      this.taskListData.push(...result.items || []) // 延展运算符的写法
    } else {
      this.taskListData = result.items // 直接赋值
    }

    this.allPage = result.pages // 总页数
    this.queryParams.page++ // 下次请求的页码
  }

  @Builder
  renderItem(item: object) {
    TaskItemCard({ taskItemData: item as TaskInfoItemModel })
  }

  // 下拉刷新函数
  async onRefresh() {
    // 重新请求第一页数据
    this.queryParams.page = 1 // 重置第一页
    await this.getTaskList(false) // 直接赋值
  }

  // 补零函数
  addZero(value: number) {
    return value.toString().padStart(2, "0")
  }

  // 获取筛选按钮是否可用
  getSearchEnable() {
    return !!(this.queryParams.startTime && this.queryParams.endTime)
  }

  @Builder
  getSearchForm() {
    Column() {
      Row() {
        Search({ placeholder: '请输入任务编号', value: this.queryParams.transportTaskId || "" })
          .backgroundColor($r('app.color.background_page'))
          .height(32)
          .onSubmit(async (value) => {
            // 点击键盘的右下角的提交
            // 4042715413936324752
            this.loading.open()
            this.allPage = 1 // 总页数为1
            this.queryParams.page = 1 // 查第一页
            if (value) {
              // 有单号的情况 如果有只有一条记录
              // 后台业务缺陷- 按道理来说 如果传单号的了 应该开始时间和结束时间自动忽略
              this.queryParams.startTime = ""
              this.queryParams.endTime = ""
              this.queryParams.transportTaskId = value
            } else {
              // 没有单号的情况下恢复之前的查询
              this.queryParams.transportTaskId = ""
            }
            await this.getTaskList(false) // 不追加数据
            this.loading.close()
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 15, right: 15, bottom: 5 })

      Row() {
        // 完成搜索页需要测试点击之后键盘和弹层同时弹出的情况
        Button(this.queryParams.startTime || '开始时间')
          .fontSize(14)
          .width(106)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onDateAccept: (value) => {
                this.queryParams.startTime =
                  `${value.getFullYear()}-${this.addZero(value.getMonth() + 1)}-${this.addZero(value.getDate())}`
              }
            })
          })

        Text("至")
        Button(this.queryParams.endTime || '结束时间')
          .fontSize(14)
          .width(110)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onDateAccept: (value) => {
                this.queryParams.endTime =
                  `${value.getFullYear()}-${this.addZero(value.getMonth() + 1)}-${this.addZero(value.getDate())}`
              }
            })
          })
        Button(this.reset ? "重置" : "筛选")
          .backgroundColor($r('app.color.primary'))
          .height(32)
          .width(60)
          .enabled(this.getSearchEnable())
          .onClick(async () => {
            if (this.reset) {
              // 表示现在需要重置 将开始时间和结束时间清空
              this.queryParams.startTime = ""
              this.queryParams.endTime = ""
            }
            this.reset = !this.reset // 状态取反

            this.loading.open()
            // 搜索
            // 处理总页数 处理第几页
            this.allPage = 1 // 默认有一页
            this.queryParams.page = 1
            // 获取数据
            await this.getTaskList(false) // true是追加 false是不追加

            this.loading.close()

          })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceAround)
    }
    .backgroundColor($r('app.color.white'))
    .padding(15)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  build() {
    Column() {
      // 是否显示搜索条件
      if (this.queryParams.status === TaskTypeEnum.Finish) {
        // 显示搜索条件
        this.getSearchForm()
      }
      ListComponents({
        dataSource: this.taskListData, // 数据源
        finished: this.allPage < this.queryParams.page, // 是否还有下一页
        // 上拉加载的函数
        onLoad: async () => {
          // 上拉加载
          await this.getTaskList(true) // 追加逻辑
        },
        onRefresh: async () => {
          // 下拉刷新
          await this.onRefresh()
        },
        renderItem: (item: object) => {
          // 如果需要的是builderParams的参数 可以用普通函数包裹一个Builder的函数
          this.renderItem(item)
        },
        loadingText: '拼命加载中',
        finishText: '触底了'
      })
        .height("100%")
    }

  }
}

export default TaskList