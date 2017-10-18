# iOS-path-smooth
iOS轨迹平滑处理示例

本工程为基于高德地图iOS SDK进行封装，实现了定位轨迹的平滑优化处理。
## 前述 ##
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[参考手册](http://a.amap.com/lbs/static/unzip/iOS_Map_Doc/AMap_iOS_API_Doc_3D/index.html).
- 工程基于iOS 3D地图SDK实现

## 功能描述 ##
基于3D地图SDK，对真实轨迹进行处理，实现去噪、平滑和抽稀。

## 效果展示 ##
![Screenshot]( https://github.com/amap-demo/iOS-path-smooth/blob/master/IMG_0038.PNG )
![Screenshot]( https://github.com/amap-demo/iOS-path-smooth/blob/master/IMG_0039.PNG )

原始轨迹和处理后轨迹

## 使用方法 ##
### 1:配置工程 ###
- pod install

### 2:实现方法 ###

`Objective-C`
``` 
- (void)initSmoothedTrace {
    MASmoothPathTool *tool = [[MASmoothPathTool alloc] init];
    tool.intensity = 3;
    tool.threshHold = 0.3;
    tool.noiseThreshhold = 10;
    self.smoothedTracePoints = [tool pathOptimize:self.origTracePoints];
    
    ...
}

```

`swift`
```
func initSmoothedTrace() {

let tool = MASmoothPathTool()
tool.intensity = 3
tool.threshHold = 0.3
tool.noiseThreshhold = 10

self.smoothedTracePoints = tool.pathOptimize(self.origTracePoints)

...
}
```
