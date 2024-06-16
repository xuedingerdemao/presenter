import TaskList from './TaskList'
import { TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import { TabClass } from '@presenter/basic'

@Preview
@Component
struct TaskTabs {
  tabController: TabsController = new TabsController()
  @State
  tabsData: TabClass[] = [{
    name: 'waiting',
    title: '待提货'
  }, {
    name: 'line',
    title: '在途'
  }, {
    name: 'finish',
    title: '已完成'
  }]
  @State
  currentIndex: number = 0

  @Builder
  getTabBar(item: TabClass) {
    Column() {
      Text(item.title)
        .fontSize(16)
        .margin({
          bottom: 10
        })
        .animation({
          duration: 300
        })
        .fontWeight(this.tabsData[this.currentIndex].name === item.name ? 600 : FontWeight.Regular)
        .fontColor(this.tabsData[this.currentIndex].name === item.name ? $r("app.color.text_primary") :
        $r("app.color.text_secondary"))
      Divider()
        .strokeWidth(4)
        .width(this.tabsData[this.currentIndex].name === item.name ? 23 : 0)
        .color($r("app.color.primary"))
        .lineCap(LineCapStyle.Round)
        .animation({
          duration: 300
        })
    }
    .onClick(() => {
      // 通过name找到索引
      const index = this.tabsData.findIndex(obj => obj.name === item.name)
      this.tabController.changeIndex(index) // 切换索引
    })
  }

  build() {
    //
    Stack({ alignContent: Alignment.Top }) {
      Tabs({ index: $$this.currentIndex, controller: this.tabController }) {
        ForEach(this.tabsData, (item: TabClass) => {
          TabContent() {
            if (item.name === 'waiting') {
              TaskList()

            } else if (item.name === 'line') {
              TaskList({
                queryParams: new TaskListParamsModel(
                  {
                    status: TaskTypeEnum.Line, // 在途的类型
                    page: 1, // 第几页
                    pageSize: 5 // 每页几条数据
                  } as TaskListParams
                )
              }) // 查询待交付的任务
            } else if (item.name === 'finish') {
              TaskList({
                queryParams: new TaskListParamsModel(
                  {
                    status: TaskTypeEnum.Finish, // 已完成类型
                    page: 1, // 第几页
                    pageSize: 5 // 每页几条数据
                  } as TaskListParams
                )
              }) // 查询待交付的任务
            }
          }
        })
      }
      .backgroundColor($r("app.color.background_page"))

      // 自定义渲染 盖住原有的内容
      Row({ space: 30 }) {
        // 有多少个就生成多少个页签
        ForEach(this.tabsData, (item: TabClass) => {
          this.getTabBar(item)
        })
      }
      .padding({
        left: 40,
        right: 40
      })
      .width("100%")
      .height(50)
      .backgroundColor($r("app.color.white"))
    }

  }
}

export default TaskTabs