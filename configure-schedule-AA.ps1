$tr1 = New-CsOnlineTimeRange -Start 07:30 -End 12:00
$tr2 = New-CsOnlineTimeRange -Start 13:00 -End 17:30
$tr3 = New-CsOnlineTimeRange -Start 13:00 -End 16:00

$businesshours = New-CsOnlineSchedule -Name "Business Hours" -WeeklyRecurrentSchedule -MondayHours @($tr1, $tr2) -TuesdayHours @($tr1, $tr2) -WednesdayHours @($tr1, $tr2) -ThursdayHours @($tr1, $tr2) -FridayHours @($tr1, $tr3)

$autoAttendant = Get-CsAutoAttendant -Identity "fa9081d6-b4f3-5c96-baec-0b00077709e5"

$BusinessHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type AfterHours -ScheduleId $businesshours.Id -CallFlowId 7dd50700-7d42-4deb-b1e9-f37201b286e4

$autoAttendant.CallHandlingAssociations += @($BusinessHoursCallHandlingAssociation)

Set-CsAutoAttendant -Instance $autoAttendant