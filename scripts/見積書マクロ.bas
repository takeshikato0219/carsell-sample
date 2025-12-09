Attribute VB_Name = "見積書マクロ"
Option Explicit

' ============================================
' Katomo 車両見積書システム VBAマクロ
' ============================================

' 見積書をクリアする
Sub ClearEstimate()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("見積書")

    Application.ScreenUpdating = False

    With ws
        ' お客様情報クリア
        .Range("C6").ClearContents  ' お客様名
        .Range("C7").ClearContents  ' 郵便番号
        .Range("C8").ClearContents  ' 住所
        .Range("C9").ClearContents  ' 電話番号

        ' 見積情報クリア
        .Range("F3").ClearContents  ' 見積日
        .Range("F4").ClearContents  ' 見積番号

        ' 車両選択クリア
        .Range("C15").ClearContents

        ' オプション選択クリア
        .Range("C18:C37").ClearContents ' オプション名
        .Range("D18:D37").ClearContents ' 数量

        ' 編集可能な諸費用クリア
        .Range("F46").ClearContents ' 納車費用
        .Range("F47").ClearContents ' 下取り手数料

        ' 下取り・値引きクリア
        .Range("F53").ClearContents ' 下取り車
        .Range("F54").ClearContents ' 下取り価格
        .Range("F55").ClearContents ' 値引き

        ' 備考クリア
        .Range("B64").ClearContents
    End With

    Application.ScreenUpdating = True

    MsgBox "見積書をクリアしました。", vbInformation, "クリア完了"
End Sub

' PDFとして出力する
Sub ExportToPDF()
    Dim ws As Worksheet
    Dim pdfPath As String
    Dim customerName As String
    Dim estimateNo As String
    Dim estimateDate As String
    Dim fileName As String
    Dim defaultPath As String

    Set ws = ThisWorkbook.Worksheets("見積書")

    ' 顧客名と見積番号を取得
    customerName = Trim(CStr(ws.Range("C6").Value))
    estimateNo = Trim(CStr(ws.Range("F4").Value))
    estimateDate = Format(ws.Range("F3").Value, "yyyymmdd")

    ' デフォルトファイル名を生成
    If customerName = "" Then customerName = "お客様"
    If estimateNo = "" Then estimateNo = Format(Now, "yyyymmdd_hhnnss")
    If estimateDate = "" Then estimateDate = Format(Date, "yyyymmdd")

    fileName = customerName & "_見積書_" & estimateDate & "_" & estimateNo

    ' 保存先選択ダイアログ
    pdfPath = Application.GetSaveAsFilename( _
        InitialFileName:=fileName & ".pdf", _
        FileFilter:="PDFファイル (*.pdf), *.pdf", _
        Title:="見積書PDFの保存先を選択")

    If pdfPath = "False" Or pdfPath = "" Then
        Exit Sub
    End If

    ' PDF出力
    On Error GoTo ErrorHandler

    ws.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        Filename:=pdfPath, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=True, _
        IgnorePrintAreas:=False, _
        OpenAfterPublish:=True

    MsgBox "PDFを保存しました:" & vbCrLf & pdfPath, vbInformation, "PDF出力完了"
    Exit Sub

ErrorHandler:
    MsgBox "PDFの出力に失敗しました。" & vbCrLf & Err.Description, vbExclamation, "エラー"
End Sub

' 印刷プレビューを表示
Sub PrintPreview()
    ThisWorkbook.Worksheets("見積書").PrintPreview
End Sub

' 直接印刷
Sub PrintEstimate()
    Dim result As VbMsgBoxResult

    result = MsgBox("見積書を印刷しますか？", vbYesNo + vbQuestion, "印刷確認")

    If result = vbYes Then
        ThisWorkbook.Worksheets("見積書").PrintOut
    End If
End Sub

' 見積番号を自動採番
Sub GenerateEstimateNumber()
    Dim ws As Worksheet
    Dim newNo As String

    Set ws = ThisWorkbook.Worksheets("見積書")

    ' 形式: K-YYYYMMDD-001
    newNo = "K-" & Format(Date, "YYYYMMDD") & "-" & Format(Int(Rnd * 900) + 100, "000")

    ws.Range("F4").Value = newNo
    ws.Range("F3").Value = Date

    MsgBox "見積番号を生成しました: " & newNo, vbInformation, "見積番号"
End Sub

' ワークブック開始時の初期化
Private Sub Workbook_Open()
    ' データシートを非表示にする（オプション）
    ' ThisWorkbook.Worksheets("データ").Visible = xlSheetVeryHidden

    ' 見積書シートを選択
    ThisWorkbook.Worksheets("見積書").Activate

    ' カーソルを車両選択セルに移動
    ThisWorkbook.Worksheets("見積書").Range("C15").Select
End Sub

' ボタン用マクロ（シートにボタンを配置する場合）
Sub Button_Clear_Click()
    Call ClearEstimate
End Sub

Sub Button_PDF_Click()
    Call ExportToPDF
End Sub

Sub Button_Print_Click()
    Call PrintEstimate
End Sub

Sub Button_NewNumber_Click()
    Call GenerateEstimateNumber
End Sub
