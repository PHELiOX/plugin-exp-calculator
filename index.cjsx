path = require 'path-extra'
{relative, join} = require 'path-extra'
{$, _, $$, React, ReactBootstrap, FontAwesome, ROOT, layout} = window
{_ships, $ships, $shipTypes} = window
{Alert, Grid, Col, Input, DropdownButton, Table, MenuItem, Button} = ReactBootstrap

row = if layout == 'horizonal' then 6 else 3
shipRow = if layout == 'horizonal' then 12 else 5
mapRow = if layout == 'horizonal' then 9 else 5
rankRow = if layout == 'horizonal' then 3 else 2

window.addEventListener 'layout.change', (e) ->
  {layout} = e.detail
  row = if layout == 'horizonal' then 6 else 3
  shipRow = if layout == 'horizonal' then 12 else 5
  mapRow = if layout == 'horizonal' then 9 else 5
  rankRow = if layout == 'horizonal' then 3 else 2

exp = [
  0, 0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600,
  4500, 5500, 6600, 7800, 9100, 10500, 12000, 13600, 15300, 17100,
  19000, 21000, 23100, 25300, 27600, 30000, 32500, 35100, 37800, 40600,
  43500, 46500, 49600, 52800, 56100, 59500, 63000, 66600, 70300, 74100,
  78000, 82000, 86100, 90300, 94600, 99000, 103500, 108100, 112800, 117600,
  122500, 127500, 132700, 138100, 143700, 149500, 155500, 161700, 168100, 174700,
  181500, 188500, 195800, 203400, 211300, 219500, 228000, 236800, 245900, 255300,
  265000, 275000, 285400, 296200, 307400, 319000, 331000, 343400, 356200, 369400,
  383000, 397000, 411500, 426500, 442000, 458000, 474500, 491500, 509000, 527000,
  545500, 564500, 584500, 606500, 631500, 661500, 701500, 761500, 851500, 1000000,
  1000000, 1010000, 1011000, 1013000, 1016000, 1020000, 1025000, 1031000, 1038000, 1046000,
  1055000, 1065000, 1077000, 1091000, 1107000, 1125000, 1145000, 1168000, 1194000, 1223000,
  1255000, 1290000, 1329000, 1372000, 1419000, 1470000, 1525000, 1584000, 1647000, 1714000,
  1785000, 1860000, 1940000, 2025000, 2115000, 2210000, 2310000, 2415000, 2525000, 2640000,
  2760000, 2887000, 3021000, 3162000, 3310000, 3465000, 3628000, 3799000, 3978000, 4165000,
  4360000, 4360000
]
expValue = [
  30, 50, 80, 100, 150, 50,
  120, 150, 200, 300, 250,
  310, 320, 330, 350, 400,
  310, 320, 330, 340, 200,
  360, 380, 400, 420, 450,
  380, 420, 100
]
expPercent = [
  1.2, 1.0, 1.0, 0.8, 0.7
]
expLevel = [
  "S", "A", "B", "C", "D"
]
expMap = [
  "1-1 鎮守府正面海域", "1-2 南西諸島沖", "1-3 製油所地帯沿岸", "1-4 南西諸島防衛線", "1-5 [Extra] 鎮守府近海", "1-6 [Extra Operation] 鎮守府近海航路",
  "2-1 カムラン半島", "2-2 バシー島沖", "2-3 東部オリョール海", "2-4 沖ノ島海域", "2-5 [Extra] 沖ノ島沖",
  "3-1 モーレイ海", "3-2 キス島沖", "3-3 アルフォンシーノ方面", "3-4 北方海域全域", "3-5 [Extra] 北方AL海域",
  "4-1 ジャム島攻略作戦", "4-2 カレー洋制圧戦", "4-3 リランカ島空襲", "4-4 カスガダマ沖海戦", "4-5 [Extra] カレー洋リランカ島沖",
  "5-1 南方海域前面", "5-2 珊瑚諸島沖", "5-3 サブ島沖海域", "5-4 サーモン海域", "5-5 [Extra] サーモン海域北方",
  "6-1 中部海域哨戒線", "6-2 MS諸島沖", "6-3 グアノ環礁沖海域"
]

expType = [
  "普通", "旗舰", "MVP", "旗舰＋MVP"
]

getExpInfo = (shipId) ->
  return [1, 100, 99] unless shipId > 0
  {$ships, _ships} = window
  idx = shipId
  goalLevel = 99
  if _ships[idx].api_lv > 99
    goalLevel = 150
  if $ships[_ships[idx].api_ship_id].api_afterlv != 0 && $ships[_ships[idx].api_ship_id].api_afterlv > _ships[idx].api_lv
    goalLevel = Math.min(goalLevel, $ships[_ships[idx].api_ship_id].api_afterlv)
  return [_ships[idx].api_lv, _ships[idx].api_exp[1], goalLevel]

module.exports =
  name: 'ExpCalcView'
  priority: 2
  displayName: [<FontAwesome key={0} name='calculator' />, ' 经验计算']
  description: '经验值计算界面'
  author: 'Chiba'
  link: 'https://github.com/Chibaheit'
  version: '1.1.0'
  reactClass: React.createClass
    getInitialState: ->
      lastShipId: 0
      _ships: null
      currentLevel: 1
      nextExp: 100
      goalLevel: 99
      mapValue: 30
      mapPercent: 1.2
      totalExp: 1000000
      expSecond: [
        Math.ceil(1000000 / 30 / 1.2),
        Math.ceil(1000000 / 30 / 1.2 / 1.5),
        Math.ceil(1000000 / 30 / 1.2 / 2.0),
        Math.ceil(1000000 / 30 / 1.2 / 3.0)
      ]
      perExp: [
        30 * 1.2,
        30 * 1.2 * 1.5,
        30 * 1.2 * 2.0,
        30 * 1.2 * 3.0
      ]
    handleExpChange: (_currentLevel, _nextExp, _goalLevel, _mapValue, _mapPercent) ->
      _currentLevel = parseInt(_currentLevel)
      _nextExp = parseInt(_nextExp)
      _goalLevel = parseInt(_goalLevel)
      _mapValue = parseInt(_mapValue)
      _totalExp = 0
      _totalExp = exp[_goalLevel] - exp[_currentLevel + 1] + _nextExp
      _noneType = Math.ceil(_totalExp / _mapValue / _mapPercent)
      _secType = Math.ceil(_totalExp / _mapValue / _mapPercent / 1.5)
      _mvpType = Math.ceil(_totalExp / _mapValue / _mapPercent / 2.0)
      _bothType = Math.ceil(_totalExp / _mapValue / _mapPercent / 3.0)
      @setState
        currentLevel: _currentLevel
        nextExp: _nextExp
        goalLevel: _goalLevel
        mapValue: _mapValue
        mapPercent: _mapPercent
        totalExp: _totalExp
        expSecond: [_noneType, _secType, _mvpType, _bothType]
        perExp: [_mapValue * _mapPercent, _mapValue * _mapPercent * 1.5, _mapValue * _mapPercent * 2.0, _mapValue * _mapPercent * 3.0]
    handleShipChange: (e) ->
      {$ships} = window
      {_ships} = @state
      if e && e.target.value != @state.lastShipId
        @state.lastShipId = e.target.value
      [_currentLevel, _nextExp, _goalLevel] = getExpInfo @state.lastShipId
      @handleExpChange _currentLevel, _nextExp, _goalLevel, @state.mapValue, @state.mapPercent
    handleCurrentLevelChange: (e) ->
      @handleExpChange e.target.value, @state.nextExp, @state.goalLevel, @state.mapValue, @state.mapPercent
    handleNextExpChange: (e) ->
      @handleExpChange @state.currentLevel, e.target.value, @state.goalLevel, @state.mapValue, @state.mapPercent
    handleGoalLevelChange: (e) ->
      console.log e.target.value
      @handleExpChange @state.currentLevel, @state.nextExp, e.target.value, @state.mapValue, @state.mapPercent
    handleExpMapChange: (e) ->
      @handleExpChange @state.currentLevel, @state.nextExp, @state.goalLevel, e.target.value, @state.mapPercent
    handleExpLevelChange: (e) ->
      @handleExpChange @state.currentLevel, @state.nextExp, @state.goalLevel, @state.mapValue, e.target.value
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      switch path
        when '/kcsapi/api_port/port'
          ships = Object.keys(window._ships).map (key) ->
            window._ships[key]
          @setState
            _ships: _.sortBy ships, (e) ->
              -e.api_lv
          @handleShipChange()
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse
    render: ->
      <div>
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'exp-calc.css')} />
        <Grid>
          <Col xs={shipRow}>
            <Input type="select" label="舰娘" value={@state.lastShipId} onChange={@handleShipChange}>
              <option key={0}>空</option>
              {
                {$ships} = window
                if @state._ships
                  for ship, i in @state._ships
                    continue unless ship?
                    shipInfo = $ships[ship.api_ship_id]
                    <option key={i + 1} value={ship.api_id}>Lv. {ship.api_lv} - {shipInfo.api_name}</option>
              }
            </Input>
          </Col>
          <Col xs={mapRow}>
            <Input type="select" label="海域" onChange={@handleExpMapChange}>
            {
              for x, i in expMap
                <option key={i} value={expValue[i]}>{x}</option>
            }
            </Input>
          </Col>
          <Col xs={rankRow}>
            <Input type="select" label="评价" onChange={@handleExpLevelChange}>
            {
              for x, i in expLevel
                <option key={i} value={expPercent[i]}>{x}</option>
            }
            </Input>
          </Col>
          <Col xs={row}>
            <Input type="number" label="目前等级" value={@state.currentLevel} onChange={@handleCurrentLevelChange} />
          </Col>
          <Col xs={row}>
            <Input type="number" label="距离下一级" value={@state.nextExp} onChange={@handleNextExpChange} />
          </Col>
          <Col xs={row}>
            <Input type="number" label="目标等级" value={@state.goalLevel} onChange={@handleGoalLevelChange} />
          </Col>
          <Col xs={row}>
            <Input type="number" label="总经验" value={@state.totalExp} readOnly />
          </Col>
        </Grid>
        <Table>
          <tbody>
            <tr key={0}>
              <td width="10%">　</td>
              <td width="30%">　</td>
              <td width="30%">每场经验</td>
              <td width="30%">剩余场数</td>
            </tr>
            {
              for x, i in expType
                [
                  <tr key={i + 1}>
                    <td width="10%">　</td>
                    <td width="30%">{expType[i]}</td>
                    <td width="30%">{@state.perExp[i]}</td>
                    <td width="30%">{@state.expSecond[i]}</td>
                  </tr>
                ]
            }
          </tbody>
        </Table>
      </div>
