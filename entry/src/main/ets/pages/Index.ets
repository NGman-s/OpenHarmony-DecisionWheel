@Entry
@Component
struct Index {
  // --- 状态变量 ---

  // 1. 定义默认占位符文本
  private readonly defaultPlaceholder: string = '请添加选项';

  // 2. 选项列表 (初始化时只有占位符)
  @State @Watch('onOptionsChange') options: string[] = [this.defaultPlaceholder];

  // 3. 转盘旋转角度
  @State rotateAngle: number = 0;
  // 4. 输入框内容
  @State inputOption: string = '';
  // 5. 结果显示
  @State selectedResult: string = '等待开始...';

  // 6. 画布设置
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // 7. 屏幕宽度
  private screenWidth: number = 300;

  // 配色方案
  private colors: string[] = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A',
    '#98FB98', '#DDA0DD', '#FFD700'
  ];

  // 监听数据变化，自动重绘
  onOptionsChange() {
    this.drawWheel();
  }

  build() {
    Column({ space: 20 }) {
      Text('脑洞转转乐')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30 })

      // --- 转盘区域 ---
      Stack({ alignContent: Alignment.Top }) {

        // 1. 转盘 (Canvas)
        Stack() {
          Canvas(this.context)
            .width('100%')
            .height('100%')
            .onReady(() => {
              this.drawWheel();
            })
        }
        .width(this.screenWidth)
        .height(this.screenWidth)
        .rotate({ angle: this.rotateAngle })
        .animation({
          duration: 4000,
          curve: Curve.FastOutSlowIn,
          iterations: 1,
          playMode: PlayMode.Normal
        })

        // 2. 指针 (固定在上方)
        Polygon()
          .points([[0, 0], [20, 0], [10, 30]])
          .fill(Color.Red)
          .stroke(Color.White)
          .strokeWidth(2)
          .width(20)
          .height(30)
          .zIndex(10)
          .margin({ top: -10 })

      }
      .width(this.screenWidth)
      .height(this.screenWidth)
      .margin({ top: 20 })

      // --- 结果展示 ---
      Text(`指针指向: ${this.selectedResult}`)
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      // --- 操作区 ---
      Button('开始转动')
        .width(200)
        .height(50)
        .fontSize(20)
        .onClick(() => {
          // 如果还是初始占位符，或者没有选项，禁止转动
          if (this.options.length === 1 && this.options[0] === this.defaultPlaceholder) {
            this.selectedResult = '请先添加选项！';
            return;
          }
          this.startSpin();
        })

      // --- 添加选项 ---
      Row({ space: 10 }) {
        TextInput({ placeholder: '输入新选项...', text: this.inputOption })
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.inputOption = value;
          })

        Button('添加')
          .height(40)
          .onClick(() => {
            this.addOption();
          })
      }
      .width('80%')

      // 重置
      Button('重置')
        .backgroundColor(Color.Gray)
        .width(100)
        .onClick(() => {
          // 重置回初始状态，只剩占位符
          this.options = [this.defaultPlaceholder];
          this.rotateAngle = 0;
          this.selectedResult = '重置完成';
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5')
  }

  // --- 逻辑：添加选项 ---
  addOption() {
    if (this.inputOption.trim() === '') return;

    // 【核心修改点】：判断当前是否是“初始占位”状态
    if (this.options.length === 1 && this.options[0] === this.defaultPlaceholder) {
      // 如果是第一次添加，清空占位符，放入新数据
      this.options = [this.inputOption];
    } else {
      // 否则正常追加
      this.options.push(this.inputOption);
    }

    this.inputOption = ''; // 清空输入框
    this.selectedResult = '选项已添加';
  }

  // --- 绘制逻辑 ---
  drawWheel() {
    let width = this.context.width;
    let height = this.context.height;
    if (!width || !height) return;

    let radius = width / 2;
    let centerX = width / 2;
    let centerY = height / 2;

    this.context.clearRect(0, 0, width, height);

    let num = this.options.length;
    if (num === 0) return;

    let arc = 2 * Math.PI / num;

    for (let i = 0; i < num; i++) {
      let startAngle = i * arc;
      let endAngle = startAngle + arc;

      this.context.beginPath();
      this.context.moveTo(centerX, centerY);
      this.context.arc(centerX, centerY, radius, startAngle, endAngle);
      this.context.closePath();

      // 如果只有一个选项，就只用第一个颜色
      this.context.fillStyle = this.colors[i % this.colors.length];
      this.context.fill();
      this.context.lineWidth = 1;
      this.context.strokeStyle = 'white';
      this.context.stroke();

      // 文字绘制
      this.context.save();
      let textAngle = startAngle + arc / 2;
      this.context.translate(centerX, centerY);
      this.context.rotate(textAngle);
      this.context.fillStyle = 'white';
      this.context.font = '20px sans-serif';
      this.context.textAlign = 'right';
      this.context.fillText(this.options[i], radius - 20, 5);
      this.context.restore();
    }
  }

  // --- 转动逻辑 ---
  startSpin() {
    if (this.options.length < 1) return;

    let randomRounds = 5 + Math.floor(Math.random() * 5);
    let randomOffset = Math.floor(Math.random() * 360);

    let currentBase = this.rotateAngle - (this.rotateAngle % 360);
    let targetAngle = currentBase + (360 * randomRounds) + randomOffset;

    this.rotateAngle = targetAngle;

    setTimeout(() => {
      this.calculateResult(targetAngle);
    }, 4000);
  }

  // --- 结果计算 ---
  calculateResult(finalAngle: number) {
    let normalizedAngle = finalAngle % 360;

    // 指针在上方 (270度)
    let pointerAngleInWheel = (270 - normalizedAngle) % 360;
    if (pointerAngleInWheel < 0) {
      pointerAngleInWheel += 360;
    }

    let sliceSpan = 360 / this.options.length;
    let index = Math.floor(pointerAngleInWheel / sliceSpan);

    if (index >= this.options.length) index = 0;
    this.selectedResult = this.options[index];
  }
}