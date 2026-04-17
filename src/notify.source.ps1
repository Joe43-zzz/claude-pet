param([string]$Type = "stop")

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$stopMessages = @(
    '😺 报告主人！活干完啦~ 快来验收喵~'
    '🍕 叮咚！您的代码外卖已送达，请给五星好评！'
    '😎 我写完了！比你想象的还快吧？嘿嘿~'
    '🏆 代码已就绪~ 本AI今日份KPI已完成！'
    '⛽ 搞定！我先去喝杯机油休息一下~'
    '🎉 任务完成！撒花~ 我是不是很棒棒？'
    '💛 嘿！代码写好了，快来夸我！'
    '💪 活干完了，奖励自己一块显卡吧~'
)

$notificationMessages = @(
    '🙀 主人主人！需要你拿个主意！快回来~'
    '🚦 前方有个岔路口，需要你来指路！'
    '🆘 SOS！我被一个权限挡住了，需要你的小手点一下~'
    '🔔 嘀嘀嘀！有个东西需要你批准，我在这等着呢~'
    '🔒 我卡住了...不是bug！是需要你的授权啦！'
    '👋 喂喂喂！你是不是忘了我？我在等你呢！'
    '🚨 紧急呼叫！需要你的确认才能继续~'
)

if ($Type -eq "stop") {
    $msg = $stopMessages | Get-Random
    $title = 'Claude 完成啦~'
    $bubbleBg = "#E8F5E9"
    $bubbleBorder = "#66BB6A"
    $titleColor = "#2E7D32"
    $petBg = "#C8E6C9"
} else {
    $msg = $notificationMessages | Get-Random
    $title = 'Claude 需要你！'
    $bubbleBg = "#FFF8E1"
    $bubbleBorder = "#FFA726"
    $titleColor = "#E65100"
    $petBg = "#FFE0B2"
}

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$iconPath = "$PSScriptRoot\..\assets\claude.png"

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Claude Pet"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        Topmost="True" ShowInTaskbar="False"
        Width="400" SizeToContent="Height"
        Left="$($screen.Right - 420)" Top="$($screen.Bottom - 200)">
    <Window.Resources>
        <Storyboard x:Key="FadeIn">
            <DoubleAnimation Storyboard.TargetProperty="Opacity" From="0" To="1" Duration="0:0:0.3"/>
            <ThicknessAnimation Storyboard.TargetName="MainPanel" Storyboard.TargetProperty="Margin"
                                From="0,20,0,0" To="0,0,0,0" Duration="0:0:0.3">
                <ThicknessAnimation.EasingFunction>
                    <CubicEase EasingMode="EaseOut"/>
                </ThicknessAnimation.EasingFunction>
            </ThicknessAnimation>
        </Storyboard>
        <Storyboard x:Key="FadeOut">
            <DoubleAnimation Storyboard.TargetProperty="Opacity" From="1" To="0" Duration="0:0:0.5"/>
            <ThicknessAnimation Storyboard.TargetName="MainPanel" Storyboard.TargetProperty="Margin"
                                From="0,0,0,0" To="0,20,0,0" Duration="0:0:0.5">
                <ThicknessAnimation.EasingFunction>
                    <CubicEase EasingMode="EaseIn"/>
                </ThicknessAnimation.EasingFunction>
            </ThicknessAnimation>
        </Storyboard>
    </Window.Resources>
    <Grid x:Name="MainPanel" Margin="10">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="80"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <!-- Claude Pet Character -->
        <Grid Grid.Column="0" VerticalAlignment="Bottom" Margin="0,0,0,5">
            <!-- Shadow -->
            <Ellipse Width="50" Height="10" VerticalAlignment="Bottom"
                     Fill="#20000000" Margin="0,0,0,-2"/>
            <!-- Body -->
            <Border Width="64" Height="64" CornerRadius="32"
                    Background="$petBg" BorderBrush="$bubbleBorder" BorderThickness="2"
                    VerticalAlignment="Bottom" Margin="0,0,0,8">
                <Border.Effect>
                    <DropShadowEffect BlurRadius="8" ShadowDepth="2" Opacity="0.2"/>
                </Border.Effect>
                <Image Source="$iconPath" Width="40" Height="40"
                       HorizontalAlignment="Center" VerticalAlignment="Center"
                       RenderOptions.BitmapScalingMode="HighQuality"/>
            </Border>
        </Grid>

        <!-- Speech Bubble -->
        <Grid Grid.Column="1" Margin="0,0,0,15">
            <!-- Bubble tail (triangle pointing to pet) -->
            <Polygon Points="0,20 12,14 12,26"
                     Fill="$bubbleBg" Stroke="$bubbleBorder" StrokeThickness="1.5"
                     HorizontalAlignment="Left" VerticalAlignment="Bottom"
                     Margin="-8,0,0,10"/>
            <!-- Bubble body -->
            <Border CornerRadius="12" Background="$bubbleBg"
                    BorderBrush="$bubbleBorder" BorderThickness="1.5"
                    Padding="14,10,14,10" Margin="4,0,4,0">
                <Border.Effect>
                    <DropShadowEffect BlurRadius="12" ShadowDepth="2" Opacity="0.15"/>
                </Border.Effect>
                <StackPanel>
                    <TextBlock Text="$title" FontSize="14" FontWeight="Bold"
                               Foreground="$titleColor" Margin="0,0,0,4"/>
                    <TextBlock Text="" FontSize="12.5" Foreground="#444444"
                               TextWrapping="Wrap" x:Name="MsgBlock" LineHeight="20"/>
                </StackPanel>
            </Border>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$msgBlock = $window.FindName("MsgBlock")
$msgBlock.Text = $msg

# Play fade-in animation
$window.Add_Loaded({
    $sb = $window.FindResource("FadeIn")
    $sb.Begin($window)
})

# Auto close with fade-out after 5 seconds
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(5)
$timer.Add_Tick({
    $timer.Stop()
    $sb = $window.FindResource("FadeOut")
    $sb.Add_Completed({ $window.Close() })
    $sb.Begin($window)
})
$timer.Start()

# Click anywhere to dismiss
$window.Add_MouseLeftButtonDown({ $window.Close() })

$window.ShowDialog() | Out-Null