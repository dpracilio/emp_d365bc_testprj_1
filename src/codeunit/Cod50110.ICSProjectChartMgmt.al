codeunit 50110 "ICS Project Chart Mgmt"
{
    trigger OnRun()
    begin

    end;

    procedure SetChartPeriod(MovePeriod: Option " ",Next,Previous; PeriodLength: Option Day,Week,Month,Quarter,Year)
    var
        PeriodFormManagementL: Codeunit PeriodFormManagement;
        SearchText: Text;
    begin
        case MovePeriod of
            MovePeriod::Next:
                SearchText := '>m';
            MovePeriod::Previous:
                SearchText := '<m';
            else
                SearchText := '';
        end;
        if PeriodLength <> PeriodLength::Quarter then
            if MovePeriod = MovePeriod::" " then
                CalendarG."Period Start" := 0D;
        if CalendarG."Period Start" = 0D then begin
            if Date2DMY(WorkDate(), 2) <> 4 then
                CalendarG.Get(PeriodLength::Year, CalcDate('<-CY>', WorkDate()))
            else
                PeriodFormManagementL.FindDate(SearchText, CalendarG, PeriodLength);
        end else
            PeriodFormManagementL.FindDate(SearchText, CalendarG, PeriodLength);
    end;

    procedure GetStatusText(PeriodLength: Option Day,Week,Month,Quarter,Year; DepartmentP: Code[20]; YearFilterP: Text; YearRangeP: Text): Text
    var
        DeptStatus: Text;
        YearFilterStatus: Text;
        YearRangeStatus: Text;
        Txt: Text;
    begin
        Clear(Txt);
        Clear(YearFilterStatus);
        Clear(YearRangeStatus);
        Clear(DeptStatus);
        if PeriodLength = PeriodLength::Quarter then begin
            if DepartmentP <> '' then
                DeptStatus := ', Dept: ' + DepartmentP;
            if (YearFilterP <> '') and (YearFilterP <> '0') then
                YearFilterStatus := 'Year: ' + YearFilterP;
            if (YearRangeP <> '') and (YearRangeP <> '0 .. 0') then
                YearRangeStatus := ', Year: ' + YearRangeP;
            Txt := YearFilterStatus + YearRangeStatus + DeptStatus;
            Txt := DelChr(Txt, '<', ',');
            if (YearFilterStatus <> '') then
                exit('Quarter No. : ' + CalendarG."Period Name" + Txt)
            else
                exit('Quarter No. : ' + CalendarG."Period Name" + ' ' + ' Year: ' + Format(Date2DMY(CalendarG."Period Start", 3)) + Txt);

        end else
            if PeriodLength = PeriodLength::Year then begin
                if DepartmentP <> '' then
                    DeptStatus := ', Dept: ' + DepartmentP;
                if (YearFilterP <> '') and (YearFilterP <> '0') then
                    YearFilterStatus := 'Year: ' + YearFilterP;
                if (YearRangeP <> '') and (YearRangeP <> '0 .. 0') then
                    YearRangeStatus := ', Year: ' + YearRangeP;
                Txt := YearFilterStatus + YearRangeStatus + DeptStatus;
                Txt := DelChr(Txt, '<', ',');
                if a = '' then begin
                    if DateFilterG1 = 0 then
                        exit('Year: ' + Format(Date2DMY(CalendarG."Period Start", 3)) + Txt)
                    else
                        exit(Txt);
                end else
                    exit(Txt);
            end;
    end;

    procedure UpdateChartData(var BusinessChartBufferP: Record "Business Chart Buffer";
        MovePeriod: Option " ",Next,Previous;
        PeriodLength: Option Day,Week,Month,Quarter,Year;
        DeptCode: Code[20];
        YearP: Integer;
        StartingYear: Integer;
        EndingYear: Integer)
    var
        CalendarL: Record Date;
        LoopCount: Integer;
        i: Integer;
    begin
        with BusinessChartBufferP do begin
            Clear(A);
            Clear(B);
            Initialize();
            SetChartPeriod(MovePeriod, PeriodLength);
            AddMeasure('In Process', 1, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            AddMeasure('Open', 2, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            AddMeasure('Completed', 3, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            AddMeasure('Planning', 4, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            AddMeasure('On Hold', 5, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            SetXAxis('Month', "Data Type"::String);

            if CalendarG."Period Type" = CalendarG."Period Type"::Quarter then
                LoopCount := 3;
            if CalendarG."Period Type" = CalendarG."Period Type"::Year then
                LoopCount := 12;

            xindex := 0;
            DateFilterG1 := StartingYear;
            DateFilterG2 := EndingYear;
            CalendarL.Reset();
            CalendarL.SetRange("Period Type", CalendarL."Period Type"::Month);

            if PeriodLength = PeriodLength::Year then begin
                if YearP <> 0 then begin
                    StartingYear := 0;
                    EndingYear := 0;
                    A := '0101' + Format(YearP) + '..' + '1231' + Format(YearP);
                    CalendarL.SetFilter("Period Start", A);
                end else
                    if StartingYear <> 0 then begin
                        YearP := 0;
                        if EndingYear = 0 then
                            Error('');
                        B := '0101' + Format(StartingYear) + '..' + '1231' + Format(StartingYear);
                        CalendarL.SetFilter("Period Start", B);
                    end else
                        CalendarL.SetFilter("Period Start", '%1..', CalcDate('<-CM', CalendarG."Period Start"));
            end else
                CalendarL.SetFilter("Period Start", '%1..', CalendarG."Period Start");

            if CalendarL.FindSet() then
                repeat
                    i += 1;
                    Clear(CompleteCountL);
                    Clear(InprocessCountL);
                    Clear(OpenCountL);
                    Clear(PlanningCountL);
                    Clear(OnHoldCountL);
                    Clear(CompleteCountL1);
                    Clear(InprocessCountL1);
                    Clear(OpenCountL1);
                    Clear(PlanningCountL1);
                    Clear(OnHoldCountL1);

                    JobG.Reset();
                    JobG.SetFilter("Starting Date", '%1..%2', CalendarL."Period Start", CalendarL."Period End");
                    if StartingYear <> 0 then
                        if EndingYear <> 0 then begin
                            JobG1.Reset();
                            JobG1.SetFilter("Starting Date", '%1..%2',
                                CalcDate('<-CM+1Y', CalendarL."Period Start"), CalcDate('<-CM+1Y', CalendarL."Period End"));
                            if DeptCode <> '' then
                                JobG1.SetRange("ICS Department", DeptCode);

                            if JobG1.FindSet() then
                                repeat
                                    case JobG1."ICS Project Status" of
                                        JobG1."ICS Project Status"::Completed:
                                            CompleteCountL1 += 1;
                                        JobG1."ICS Project Status"::"In Process":
                                            InprocessCountL1 += 1;
                                        JobG1."ICS Project Status"::Planning:
                                            PlanningCountL1 += 1;
                                        JobG1."ICS Project Status"::Open:
                                            OpenCountL1 += 1;
                                        JobG1."ICS Project Status"::"On Hold":
                                            OnHoldCountL1 += 1;
                                    end;
                                until JobG1.Next() = 0;
                        end;
                    if DeptCode <> '' then
                        JobG.SetRange("ICS Department", DeptCode);

                    if JobG.FindSet() then
                        repeat
                            case JobG."ICS Project Status" of
                                JobG."ICS Project Status"::Completed:
                                    CompleteCountL += 1;
                                JobG."ICS Project Status"::"In Process":
                                    InprocessCountL += 1;
                                JobG."ICS Project Status"::Planning:
                                    PlanningCountL += 1;
                                JobG."ICS Project Status"::Open:
                                    OpenCountL += 1;
                                JobG."ICS Project Status"::"On Hold":
                                    OnHoldCountL += 1;
                            end;
                        until JobG.Next() = 0;

                    if (CompleteCountL <> 0) or (InprocessCountL <> 0) or (OpenCountL <> 0) or
                    (PlanningCountL <> 0) or (CompleteCountL1 <> 0) or (InprocessCountL1 <> 0) or
                    (OpenCountL1 <> 0) or (PlanningCountL1 <> 0) then begin
                        AddColumn(CalendarL."Period Name");
                        SetValue('In Process', xindex, Round(InprocessCountL + InprocessCountL1, 0.01, '='));
                        SetValue('Open', xindex, Round(OpenCountL + OpenCountL1, 0.01, '='));
                        SetValue('Completed', xindex, Round(CompleteCountL + CompleteCountL1, 0.01, '='));
                        SetValue('Planning', xindex, Round(PlanningCountL + PlanningCountL1, 0.01, '='));
                        SetValue('On Hold', xindex, Round(OnHoldCountL + OnHoldCountL1, 0.01, '='));
                        xindex += 1;
                    end;
                until (i = LoopCount) or (CalendarL.Next() = 0);
        end;
    end;

    procedure ChartDrillDown(var Point: JsonObject; DeptCode: Code[20])
    var
        Job: Record Job;
        CalendarL: Record Date;
        JobList: Page "Job List";
        FromDateL: Date;
        FromDateL1: Date;
        ToDateL: Date;
        ToDateL1: Date;
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

        CalendarL.Reset();
        CalendarL.SetRange("Period Type", CalendarL."Period Type"::Month);
        if A <> '' then
            CalendarL.SetFilter("Period Start", A)
        else
            if B <> '' then
                CalendarL.SetFilter("Period Start", B)
            else
                CalendarL.SetFilter("Period Start", '%1..', CalcDate('<-CM>', CalendarG."Period Start"));
        if CalendarL.FindSet() then
            repeat
                if CalendarL."Period Name" = XValueString then begin
                    FromDateL := CalendarL."Period Start";
                    ToDateL1 := CalcDate('<CM>', CalendarL."Period Start");
                    if (CalendarL."Period No." = 1) or (CalendarL."Period No." = 2) or (CalendarL."Period No." = 3) then begin
                        FromDateL := CalcDate('<-CM>', FromDateL);
                        ToDateL1 := CalcDate('<-CM>', ToDateL1);
                    end;
                    if B <> '' then
                        if DateFilterG2 - DateFilterG1 = 1 then begin
                            FromDateL1 := CalcDate('<-CM+1Y', FromDateL1);
                            ToDateL1 := CalcDate('<CM+1Y>', ToDateL1)
                        end;
                end;
            until (CalendarL."Period Name" = XValueString) or (CalendarL.Next() = 0);

        Job.Reset();
        Job.FilterGroup(2);
        if B <> '' then
            Job.SetFilter("Starting Date", '%1..%2|%3..%4', FromDateL, ToDateL1, FromDateL1, ToDateL1)
        else
            Job.SetFilter("Starting Date", '%1..%2', FromDateL1, ToDateL1);

        if DeptCode <> '' then
            Job.SetRange("ICS Department", DeptCode);

        case Measures of
            'In Process':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::"In Process");
            'Open':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::Open);
            'Completed':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::Completed);
            'On Hold':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::"On Hold");
            'Planning':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::Planning);
        end;
        JobList.SetTableView(Job);
        Job.FilterGroup(0);
        JobList.RunModal();
    end;

    var
        CalendarG: Record Date;
        JobG: Record Job;
        JobG1: Record Job;
        A: Text;
        B: Text;
        xindex: Integer;
        DateFilterG1: Integer;
        DateFilterG2: Integer;
        InprocessCountL: Integer;
        OpenCountL: Integer;
        PlanningCountL: Integer;
        CompleteCountL: Integer;
        OnHoldCountL: Integer;
        InprocessCountL1: Integer;
        OpenCountL1: Integer;
        PlanningCountL1: Integer;
        CompleteCountL1: Integer;
        OnHoldCountL1: Integer;
}