## MyGO!!!!! ����Ʒ�ϵͳ��Early_Reading_Scoring_System��

һ������ Qt 6 QML/Quick �ļ��Ʒֿ��壬���ڰ༶/С������ӷ�չʾ��ͳ�ơ�

### ���ܸ���
- **��Ա��/����**�������Աͷ����мӷ֣��ٴε���ɳ������շ�����
- **ͳ����ͼ**������������״ͼͳ����ͼһ���л���
- **ȫ��/����Ӧ**������ `resources/config.json` �еķֱ����Զ��������Ż�ȫ����ʾ��
- **��̬�İ��뿪������**��֧�������ֲ�������������������Դ���ء�

### ���л���
- Qt 6.8+����Ŀʹ�� `qt_standard_project_setup(REQUIRES 6.8)`��
- �����Qt Quick��QML��
- CMake 3.16+
- Windows�����ṩ `icon.rc` �뷢���ű�/Ŀ¼������������ƽ̨����� Qt ֧�����й���

### Ŀ¼�ṹ����ѡ��
- `main.cpp`��Ӧ����ڣ�ע�� `GlobalFunc` �� QML������ `page/Main.qml`
- `globalfunc.h/.cpp`�������빤�ߺ�������ȡ/д�� JSON���Ŷ�/�����߼�������ע��ȣ�
- `page/`��QML ���棨`Main.qml`��`TeamItem.qml`��`BarChart.qml` �ȣ�
- `resources/`��ͼƬ�����������ã�`config.json`��`team.json` �ȣ�
- `CMakeLists.txt`���������ã�����Դ����Ŀ�� `copy_resources`��

### ���ٿ�ʼ
#### Qt Creator
1. ����Ŀ��Ŀ¼�� `CMakeLists.txt`��
2. ѡ�� Qt 6 kit���� MinGW 64-bit �� MSVC�������ò����롣
3. ����Ŀ�꣺`appEarly_Reading_Scoring_System`��

������CMake �Զ���Ŀ���� `resources/` �� `page/` ���Ƶ�����Ŀ¼��ȷ������ʱ�ܼ��ص��ⲿ QML ����Դ��

### ��������
- ����ʱ����� `resources/` �� `page/`��CMake ���ڹ����׶��Զ����Ƶ�����Ŀ¼��
- ��װcqtdeployer�Դ��

```
cqtdeployer -bin appEarly_Reading_Scoring_System.exe -qmake E:\Code\tools\Qt\6.9.2\mingw_64\bin\qmake.exe -qmlDir E:\Code\tools\Qt\6.9.2\mingw_64\qml -qmlOut ku -libOut ku -pluginOut ku
```
