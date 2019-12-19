codeunit 50115 "Fin. Perform. Chart Mgmt"
{
    procedure UpdateChartData(var BusinessChartBuffer: Record "Business Chart Buffer")
    var
        ColumnIndex: Integer;
        JobPostGrp: Record "Job Posting Group";
        JobPostGrpCode: List of [Code[20]];
        JobPostGrpName: List of [Text];
        NoOfJobs: List of [Integer];
        NoOfActiveJobs: List of [Integer];

        BusChartMapColumn: Record "Business Chart Map";
        BusChartMapMeasure: Record "Business Chart Map";
        GLEntry: Record "G/L Entry";
        FromDate: Date;
        ToDate: Date;
        Amount: Decimal;
        Accumulate: Boolean;
    begin
        with BusinessChartBuffer do begin
            Initialize();
            "Period Length" := "Period Length"::Month;
            SetPeriodXAxis();
            if CalcPeriods(BusinessChartBuffer) then begin
                AddMeasure('Amount', '', "Data Type"::Decimal, "Chart Type"::Line);

                if FindFirstMeasure(BusChartMapMeasure) then
                    repeat
                        //Accumulate := BusChartMapMeasure.Name = 'Amount';
                        if FindFirstColumn(BusChartMapColumn) then
                            repeat
                                ToDate := BusChartMapColumn.GetValueAsDate();

                                //if Accumulate then
                                //FromDate := WorkDate()
                                //else
                                FromDate := CalcFromDate(ToDate);

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

                                // Message(Format(BusChartMapMeasure."Value String"));
                                SetValue(BusChartMapMeasure.Name, BusChartMapColumn.Index, Amount);
                            until not NextColumn(BusChartMapColumn);
                    until not NextMeasure(BusChartMapMeasure);


                // AddMeasure('No. of Jobs', 1, "Data Type"::Integer, "Chart Type"::Doughnut);
                // SetXAxis('Job Posting Group', "Data Type"::String);
                // CalcNoOfJobsPerPostGrp(JobPostGrpCode, JobPostGrpName, NoOfJobs);
                // for ColumnIndex := 1 to NoOfJobs.Count do begin
                //     AddColumn(JobPostGrpName.Get(ColumnIndex));
                //     SetValue('No. of Jobs', ColumnIndex - 1, NoOfJobs.Get(ColumnIndex));
            end;
        end;
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

    local procedure CalcJobAmounts(var JobPostGrp: Record "Job Posting Group"; var JobName: List of [Text]; var InvoicedAmount: List of [Decimal]; var CostAmount: List of [Decimal]; var RevenueAmount: List of [Decimal]; var NoOfActiveJobs: Integer)
    var
        Job: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
        InvoicedAmountLCY: Decimal;
        CostAmountLCY: Decimal;
    begin
        Job.Reset();
        Job.SetRange("Job Posting Group", JobPostGrp.Code);
        Job.SetRange(Status, Job.Status::Open);
        Job.FindFirst();
        repeat
            Clear(InvoicedAmountLCY);
            Clear(CostAmountLCY);

            JobLedgerEntry.Reset();
            JobLedgerEntry.SetCurrentKey("Job No.", "Entry Type", "Posting Date");
            JobLedgerEntry.SetRange("Job No.", Job."No.");
            JobLedgerEntry.SetRange("Entry Type", JobLedgerEntry."Entry Type"::Sale);
            if JobLedgerEntry.FindFirst() then
                repeat
                    InvoicedAmountLCY := InvoicedAmountLCY + JobLedgerEntry."Line Amount (LCY)";
                until JobLedgerEntry.Next() = 0;

            JobLedgerEntry.Reset();
            JobLedgerEntry.SetCurrentKey("Job No.", "Entry Type", "Posting Date");
            JobLedgerEntry.SetRange("Job No.", Job."No.");
            JobLedgerEntry.SetRange("Entry Type", JobLedgerEntry."Entry Type"::Usage);
            if JobLedgerEntry.FindFirst() then
                repeat
                    CostAmountLCY := CostAmountLCY + JobLedgerEntry."Line Amount (LCY)";
                until JobLedgerEntry.Next() = 0;

            NoOfActiveJobs := NoOfActiveJobs + 1;

            JobName.Add(Job.Description);
            InvoicedAmount.Add(-InvoicedAmountLCY);
            CostAmount.Add(CostAmountLCY);
            RevenueAmount.Add(-InvoicedAmountLCY - CostAmountLCY);
        until Job.Next() = 0;
    end;

    local procedure CalcNoOfJobsPerPostGrp(var JobPostGrpCode: List of [Code[20]]; var JobPostGrpName: List of [Text]; var NoOfJobs: List of [Integer])
    var
        Job: Record Job;
        JobPostGrp: Record "Job Posting Group";
    begin
        JobPostGrp.Reset();
        if JobPostGrp.FindFirst() then
            repeat
                Job.Reset();
                Job.SetRange("Job Posting Group", JobPostGrp.Code);
                Job.SetRange(Status, Job.Status::Open);

                if Job.Count <> 0 then begin
                    JobPostGrpName.Add(JobPostGrp.Description);
                    JobPostGrpCode.Add(JobPostGrp.Code);
                    NoOfJobs.Add(Job.Count);
                end;

            until JobPostGrp.Next() = 0;
    end;

    local procedure CalcPeriods(var BusChartBuf: Record "Business Chart Buffer"): Boolean
    var
        Which: Option First,Last;
        FromDate: Date;
        ToDate: Date;
    begin
        // FromDate := GetEntryDate(CashFlowForecast, Which::First);
        // ToDate := GetEntryDate(CashFlowForecast, Which::Last);
        FromDate := 20190101D;
        ToDate := 20191230D;
        if ToDate <> 0D then
            BusChartBuf.AddPeriods(FromDate, ToDate);
        exit(ToDate <> 0D);
    end;

    var
}