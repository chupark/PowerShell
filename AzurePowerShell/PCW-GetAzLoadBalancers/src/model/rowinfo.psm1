class rowInfo {
    [int]$countnum
    [String]$lbName
    [String]$lbKind
    [String]$frontEndIP
    [String]$lbBackEndName
    [String]$backendPool
    [String]$probeRule
    [String]$ruleProtocol
    [String]$rulePort

    [String]ToString() {
        return ("{0}{1}{2}{3}{4}{5}{6}{7}" -f $this.countnum, $this.lbName, $this.lbKind, $this.frontEndIP, $this.lbBackEndName, $this.backendPool, $this.probeRule, $this.ruleProtocol, $this.rulePort)
    }
}

class rack {
    [rowInfo[]]$rowInfos = [rowInfo[]]::new()

    [void]addRowsss([rowInfo]$rInf) {
        $this.rowInfos = $rInf
    }
}

$rck = [rack]::new

$rowInfo = [rowInfo]::new()
$rowInfo.countnum = 1
$rowInfo.frontEndIP = "1.1.1.1"

$rck.addRowsss($rowInfo)