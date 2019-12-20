codeunit 50115 "Fin. Perform. Chart Mgmt"
{
    procedure UpdateChartData(var BusinessChartBuffer: Record "Business Chart Buffer"; Period: Option " ",Next,Previous): Boolean
    var
        ColumnIndex: Integer;
        JobPostGrp: Record "Job Posting Group";
        JobPostGrpCode: List of [Code[20]];
        JobPostGrpName: List of [Text];
        NoOfJobs: List of [Integer];
        NoOfActiveJobs: List of [Integer];

        BusChartMapColumn: Record "Business Chart Map";
        BusChartMapMeasure: Record "Business Chart Map";
        FinPerformChartSetup: Record "Fin. Perform. Chart Setup";
        GLEntry: Record "G/L Entry";
        FromDate: Date;
        ToDate: Date;
        Amount: Decimal;
        Accumulate: Boolean;
        NoOfPeriods: Integer;
        PeriodCounter: Integer;
        PeriodLength: Text[1];
        i: Integer;
    begin
        FinPerformChartSetup.Get(UserId);

        with BusinessChartBuffer do begin
            if Period = Period::" " then begin
                FromDate := 0D;
                ToDate := 0D;
            end else
                if FindMidColumn(BusChartMapColumn) then
                    GetPeriodFromMapColumn(BusChartMapColumn.Index, FromDate, ToDate);

            Initialize();
            "Period Length" := FinPerformChartSetup."Period Length";
            SetPeriodXAxis();
            InitParameters(BusinessChartBuffer, PeriodLength, NoOfPeriods);
            CalcAndInsertPeriodAxis(BusinessChartBuffer, Period, NoOfPeriods, FromDate, ToDate);

            AddMeasure('Amount', '', "Data Type"::Decimal, "Chart Type"::Column);
            AddMeasure('Income', '', "Data Type"::Decimal, "Chart Type"::Column);
            AddMeasure('Expenses', '', "Data Type"::Decimal, "Chart Type"::Column);

            FindFirstColumn(BusChartMapColumn);
            for PeriodCounter := 1 to NoOfPeriods do begin
                GetPeriodFromMapColumn(PeriodCounter - 1, FromDate, ToDate);

                // Randomize(CurrentDateTime() - CreateDateTime(Today(), 0T));
                Amount := 0;

                GLEntry.Reset();
                GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
                GLEntry.SetRange("G/L Account No.", '2310');
                GLEntry.SetFilter("Posting Date", '%1..%2', FromDate, ToDate);
                GLEntry.SetRange("Document Type", GLEntry."Document Type"::Invoice);
                if GLEntry.FindFirst() then
                    repeat
                        Amount := Amount + GLEntry.Amount;
                    until GLEntry.Next() = 0;

                SetValue('Amount', PeriodCounter - 1, Amount);
                SetValue('Income', PeriodCounter - 1, Amount);
                SetValue('Expenses', PeriodCounter - 1, Amount);
            end;
        end;
        exit(true);
    end;

    procedure ChartDrillDown(var Point: JsonObject)
    var
        Job: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
        JobList: Page "Job List";
        JobLedgerEntries: Page "Job Ledger Entries";
        Measures: Text;
        XValueString: Text;
        JsonTokenMeasures: JsonToken;
        JsonTokenXValueString: JsonToken;
    begin
        if Point.Get('Measures', JsonTokenMeasures) then begin
            Measures := Format(JsonTokenMeasures);
            Measures := DelChr(Measures, '=', '["]');
        end;
        if Point.Get('XValueString', JsonTokenXValueString) then begin
            XValueString := Format(JsonTokenXValueString);
            XValueString := DelChr(XValueString, '=', '"');
        end;

        Clear(JobLedgerEntries);

        Job.Reset();
        Job.SetRange(Description, XValueString);
        Job.FindFirst();

        JobLedgerEntry.Reset();
        JobLedgerEntry.FilterGroup(2);
        JobLedgerEntry.SetCurrentKey("Job No.", "Entry Type", "Posting Date");
        JobLedgerEntry.SetRange("Job No.", Job."No.");
        JobLedgerEntries.SetTableView(JobLedgerEntry);
        JobLedgerEntry.FilterGroup(0);
        JobLedgerEntries.RunModal();
    end;

    local procedure InitParameters(BusChartBuf: Record "Business Chart Buffer"; var PeriodLength: Text[1]; var NoOfPeriods: Integer)
    begin
        PeriodLength := GetPeriod(BusChartBuf);
        NoOfPeriods := GetNoOfPeriods(BusChartBuf);
    end;

    local procedure GetPeriod(BusChartBuf: Record "Business Chart Buffer"): Text[1]
    begin
        if BusChartBuf."Period Length" = BusChartBuf."Period Length"::None then
            exit('M');
        exit(BusChartBuf.GetPeriodLength());
    end;

    local procedure GetNoOfPeriods(BusChartBuf: Record "Business Chart Buffer"): Integer
    var
        OfficeMgt: Codeunit "Office Management";
        NoOfPeriods: Integer;
    begin
        NoOfPeriods := 14;
        case BusChartBuf."Period Length" of
            BusChartBuf."Period Length"::Day:
                NoOfPeriods := 16;
            BusChartBuf."Period Length"::Week,
            BusChartBuf."Period Length"::Quarter:
                if OfficeMgt.IsAvailable() then
                    NoOfPeriods := 6
                else
                    NoOfPeriods := 14;
            BusChartBuf."Period Length"::Month:
                if OfficeMgt.IsAvailable() then
                    NoOfPeriods := 5
                else
                    NoOfPeriods := 14;
            BusChartBuf."Period Length"::Year:
                if OfficeMgt.IsAvailable() then
                    NoOfPeriods := 5
                else
                    NoOfPeriods := 7;
            BusChartBuf."Period Length"::None:
                NoOfPeriods := 7;
        end;

        exit(NoOfPeriods);
    end;

    local procedure CalcAndInsertPeriodAxis(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; MaxPeriodNo: Integer; StartDate: Date; EndDate: Date)
    var
        PeriodDate: Date;
    begin
        if (StartDate = 0D) and (BusChartBuf."Period Filter Start Date" <> 0D) then
            PeriodDate := CalcDate(StrSubstNo('<-1%1>', BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter Start Date")
        else begin
            BusChartBuf.RecalculatePeriodFilter(StartDate, EndDate, Period);
            RecalculatePeriodFilter(BusChartBuf, StartDate, EndDate, Period);
            // PeriodDate := CalcDate(StrSubstNo('<-%1%2>', MaxPeriodNo, BusChartBuf.GetPeriodLength()), EndDate);
            PeriodDate := CalcDate(StrSubstNo('<-%1%2>', MaxPeriodNo - (MaxPeriodNo div 2), BusChartBuf.GetPeriodLength), EndDate);
        end;

        BusChartBuf.AddPeriods(GetCorrectedDate(BusChartBuf, PeriodDate, 1), GetCorrectedDate(BusChartBuf, PeriodDate, MaxPeriodNo));
    end;

    procedure RecalculatePeriodFilter(var BusChartBuf: Record "Business Chart Buffer"; var StartDate: Date; var EndDate: Date; MovePeriod: Option " ",Next,Previous)
    var
        Calendar: Record Date;
        PeriodFormMgt: Codeunit PeriodFormManagement;
        SearchText: Text[3];
    begin
        if StartDate <> 0D then begin
            Calendar.SetFilter("Period Start", '%1..%2', StartDate, EndDate);
            if not PeriodFormMgt.FindDate('+', Calendar, BusChartBuf."Period Length") then
                PeriodFormMgt.FindDate('+', Calendar, Calendar."Period Type"::Date);
            Calendar.SetRange("Period Start");
        end;

        case MovePeriod of
            MovePeriod::Next:
                SearchText := '>=';
            MovePeriod::Previous:
                SearchText := '<=';
            else
                SearchText := '';
        end;

        PeriodFormMgt.FindDate(SearchText, Calendar, BusChartBuf."Period Length");

        StartDate := Calendar."Period Start";
        EndDate := Calendar."Period End";
    end;

    local procedure GetCorrectedDate(BusChartBuf: Record "Business Chart Buffer"; InputDate: Date; PeriodNo: Integer) OutputDate: Date
    begin
        OutputDate := CalcDate(StrSubstNo('<%1%2>', PeriodNo, BusChartBuf.GetPeriodLength()), InputDate);
        if BusChartBuf."Period Length" <> BusChartBuf."Period Length"::Day then
            OutputDate := CalcDate(StrSubstNo('<C%1>', BusChartBuf.GetPeriodLength()), OutputDate);
    end;

    procedure OnOpenPage(var FinPerformChartSetup: Record "Fin. Perform. Chart Setup")
    begin
        with FinPerformChartSetup do
            if not Get(UserId) then begin
                "User ID" := UserId;
                "Start Date" := "Start Date"::"Working Date";
                "Period Length" := "Period Length"::Month;
                Insert;
            end;
    end;

    var
}