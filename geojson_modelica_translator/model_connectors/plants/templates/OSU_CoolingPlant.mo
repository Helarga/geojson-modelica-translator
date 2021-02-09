within geojson_modelica_translator.model_connectors.templates;
model OSU_CoolingPlant
  package Medium = Buildings.Media.Water "Medium model";

  parameter Integer numChi(min=1, max=2)=2 "Number of chillers, maximum is 2";

  parameter Boolean show_T = true
    "= true, if actual temperature at port is computed"
    annotation(Dialog(tab="Advanced",group="Diagnostics"));
  replaceable parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic perChi
    "Performance data of chiller"
    annotation (Dialog(group="Chiller"), choicesAllMatching = true,
    Placement(transformation(extent={{98,82},{112,96}})));
  parameter Modelica.SIunits.MassFlowRate mCHW_flow_nominal
    "Nominal chilled water mass flow rate"
    annotation (Dialog(group="Chiller"));
  parameter Modelica.SIunits.MassFlowRate mCHWPum_flow_nominal
  "Nominal chilled water pump mass flow rate";
  parameter Modelica.SIunits.Pressure dpCHW_nominal
    "Pressure difference at the chilled water side"
    annotation (Dialog(group="Chiller"));
  parameter Modelica.SIunits.Power QEva_nominal=perChi.QEva_flow_nominal
    "Nominal cooling capacity of single chiller (negative means cooling)"
    annotation (Dialog(group="Chiller"));
  parameter Modelica.SIunits.MassFlowRate mMin_flow
    "Minimum mass flow rate of single chiller"
    annotation (Dialog(group="Chiller"));
  parameter Modelica.SIunits.MassFlowRate mCW_flow_nominal
    "Nominal condenser water mass flow rate"
    annotation (Dialog(group="Cooling Tower"));
  parameter Modelica.SIunits.Pressure dpCW_nominal
    "Pressure difference at the condenser water side"
    annotation (Dialog(group="Cooling Tower"));
  parameter Modelica.SIunits.Temperature TAirInWB_nominal
    "Nominal air wetbulb temperature"
    annotation (Dialog(group="Cooling Tower"));
  parameter Modelica.SIunits.Temperature TCW_nominal
    "Nominal condenser water temperature at tower inlet"
    annotation (Dialog(group="Cooling Tower"));
  parameter Modelica.SIunits.TemperatureDifference dT_nominal
    "Temperature difference between inlet and outlet of the tower"
     annotation (Dialog(group="Cooling Tower"));
  parameter Modelica.SIunits.Temperature TMin
    "Minimum allowed water temperature entering chiller"
    annotation (Dialog(group="Cooling Tower"));
  parameter Modelica.SIunits.Power PFan_nominal
    "Fan power"
    annotation (Dialog(group="Cooling Tower"));
  replaceable parameter Buildings.Fluid.Movers.Data.Generic perCHWPum
    constrainedby Buildings.Fluid.Movers.Data.Generic
    "Performance data of chilled water pump"
    annotation (Dialog(group="Pump"),choicesAllMatching=true,
      Placement(transformation(extent={{120,82},{134,96}})));
  replaceable parameter Buildings.Fluid.Movers.Data.Generic perCWPum
    constrainedby Buildings.Fluid.Movers.Data.Generic
    "Performance data of condenser water pump"
    annotation (Dialog(group="Pump"),choicesAllMatching=true,
      Placement(transformation(extent={{142,82},{156,96}})));
  parameter Modelica.SIunits.Pressure dpCHWPum_nominal
    "Nominal pressure drop of chilled water pumps"
    annotation (Dialog(group="Pump"));
  parameter Modelica.SIunits.Pressure dpCWPum_nominal
    "Nominal pressure drop of condenser water pumps"
    annotation (Dialog(group="Pump"));
  parameter Modelica.SIunits.Time tWai "Waiting time"
    annotation (Dialog(group="Control Settings"));
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));
  parameter Modelica.Fluid.Types.Dynamics massDynamics=energyDynamics
    "Type of mass balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true, Dialog(tab = "Dynamics", group="Equations"));

  Medium.ThermodynamicState sta_a=
      Medium.setState_phX(port_a.p,
                          noEvent(actualStream(port_a.h_outflow)),
                          noEvent(actualStream(port_a.Xi_outflow))) if
         show_T "Medium properties in port_a";

  Medium.ThermodynamicState sta_b=
      Medium.setState_phX(port_b.p,
                          noEvent(actualStream(port_b.h_outflow)),
                          noEvent(actualStream(port_b.Xi_outflow))) if
          show_T "Medium properties in port_b";

  Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium = Medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{150,40},{170,60}}),
        iconTransformation(extent={{90,40},{110,60}})));

  Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium = Medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{150,-60},{170,-40}}),
        iconTransformation(extent={{90,-60},{110,-40}})));

  Modelica.Blocks.Interfaces.BooleanInput on "On signal of the plant"
    annotation (Placement(transformation(extent={{-160,48},{-140,68}}),
        iconTransformation(extent={{-140,60},{-100,100}})));

  Modelica.Blocks.Interfaces.RealInput TCHWSupSet(
    final unit="K",
    displayUnit="degC")
    "Set point for chilled water supply temperature"
    annotation (Placement(transformation(extent={{-160,14},{-140,34}}),
        iconTransformation(extent={{-140,10},{-100,50}})));

  Modelica.Blocks.Interfaces.RealInput TWetBul(
    final unit="K",
    displayUnit="degC")
    "Entering air wetbulb temperature"
    annotation (Placement(transformation(extent={{-160,-62},{-140,-42}}),
        iconTransformation(extent={{-140,-100},{-100,-60}})));

  Buildings.Applications.DataCenters.ChillerCooled.Equipment.ElectricChillerParallel mulChiSys(
    show_T=true,
    per=fill(perChi, numChi),
    m1_flow_nominal=mCHW_flow_nominal,
    m2_flow_nominal=mCW_flow_nominal,
    dp1_nominal=dpCHW_nominal,
    dp2_nominal=dpCW_nominal,
    num=numChi,
    redeclare package Medium1=Medium,
    redeclare package Medium2=Medium) "Chillers connected in parallel"
    annotation (Placement(transformation(extent={{10,20},{-10,0}})));
  Buildings.Experimental.OSU.CentralPlants.Cooling.Subsystems.CoolingTowerWithBypass cooTowWitByp(
    redeclare package Medium = Medium,
    show_T=true,
    num=numChi,
    m_flow_nominal=mCW_flow_nominal,
    dp_nominal=dpCW_nominal,
    TAirInWB_nominal=TAirInWB_nominal,
    TWatIn_nominal=TCW_nominal,
    dT_nominal=dT_nominal,
    PFan_nominal=PFan_nominal,
    TMin=TMin) "Cooling towers with bypass valve"
    annotation (Placement(transformation(extent={{-56,-60},{-36,-40}})));
  Applications.DataCenters.ChillerCooled.Equipment.FlowMachine_y priPumCHW(
    redeclare package Medium = Medium,
    per=fill(perCHWPum, numChi),
    riseTimePump=100,
    energyDynamics=energyDynamics,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=dpCHWPum_nominal,
    num=numChi) "Primary Chilled water pumps."
    annotation (Placement(transformation(extent={{10,40},{-10,60}})));
  Buildings.Applications.DataCenters.ChillerCooled.Equipment.FlowMachine_m pumCW(
    redeclare package Medium = Medium,
    per=fill(perCWPum, numChi),
    energyDynamics=energyDynamics,
    m_flow_nominal=mCW_flow_nominal,
    dpValve_nominal=dpCWPum_nominal,
    num=numChi) "Condenser water pumps"
    annotation (Placement(transformation(extent={{-10,-60},{10,-40}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTCHWSup(
    redeclare package Medium = Medium,
    m_flow_nominal=mCHW_flow_nominal) "Chilled water supply temperature"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={130,-50})));
  Heating.Generation4.Controls.OSUPrimaryWaterPumpSpeed priPumSpe(tWai=0)
    "Chilled water pump controller"
    annotation (Placement(transformation(extent={{-120,-20},{-100,0}})));
  Controls.ChillerStageOSU chiStaCon(
    tWai=tWai,
    QEva_flow_nominal=perChi.QEva_flow_nominal)
    "Chiller staging controller"
    annotation (Placement(transformation(extent={{-118,50},{-98,70}})));
  Modelica.Blocks.Math.RealToBoolean chiOn[numChi]
    "Real value to boolean value"
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));

  Modelica.Blocks.Sources.RealExpression priFlo(y=mulChiSys.port_a2.m_flow)
    "Chilled water total mass flow rate"
    annotation (Placement(transformation(extent={{-100,-44},{-120,-24}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTCHWRet(redeclare package
      Medium =  Medium,
      m_flow_nominal=mCHW_flow_nominal) "Chilled water return temperature"
    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={78,50})));
  Buildings.Fluid.Sources.Boundary_pT expTanCW(redeclare package Medium = Medium,
    nPorts=1) "Condenser water expansion tank"
    annotation (Placement(transformation(extent={{-44,-30},{-24,-10}})));

  Buildings.Fluid.Sensors.MassFlowRate actPri(redeclare package Medium = Medium)
    "Chilled water return mass flow"
    annotation (Placement(transformation(extent={{136,40},{116,60}})));

  Fluid.Sensors.MassFlowRate deCou(redeclare package Medium = Medium)
    "Chilled water bypass valve mass flow meter" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={60,26})));
  Fluid.Sources.Boundary_pT expTan(redeclare package Medium = Medium, nPorts=1)
    "Primary circuit expansion tank" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={44,66})));
protected
  final parameter Medium.ThermodynamicState sta_default = Medium.setState_pTX(
    T=Medium.T_default,
    p=Medium.p_default,
    X=Medium.X_default) "Medium state at default properties";
  final parameter Modelica.SIunits.SpecificHeatCapacity cp_default=
    Medium.specificHeatCapacityCp(sta_default)
    "Specific heat capacity of the fluid";

equation

  connect(senTCHWSup.port_b, port_b) annotation (Line(
      points={{140,-50},{160,-50}},
      color={0,127,255}));
  connect(cooTowWitByp.port_b, pumCW.port_a) annotation (Line(points={{-36,-50},
          {-10,-50}},                                                                       color={0,127,255}));
  connect(on, chiStaCon.on) annotation (Line(points={{-150,58},{-138,58},{-138,
          52.4},{-119,52.4}},
                      color={255,0,255}));
  connect(chiStaCon.y, cooTowWitByp.on) annotation (Line(points={{-97,53},{-90,
          53},{-90,-46},{-58,-46}},
                                color={0,0,127}));
  connect(chiStaCon.y, pumCW.u) annotation (Line(points={{-97,53},{-90,53},{-90,
          -34},{-30,-34},{-30,-46},{-12,-46}}, color={0,0,127}));
  connect(TWetBul, cooTowWitByp.TWetBul) annotation (Line(points={{-150,-52},{
          -58,-52}},                 color={0,0,127}));
  connect(chiStaCon.y, chiOn.u) annotation (Line(points={{-97,53},{-90,53},{-90,
          60},{-82,60}},                         color={0,0,127}));
  connect(mulChiSys.port_b1, cooTowWitByp.port_a) annotation (Line(points={{-10,4},
          {-70,4},{-70,-50},{-56,-50}},    color={0,127,255}));
  connect(chiOn.y, mulChiSys.on) annotation (Line(points={{-59,60},{-48,60},{-48,
          32},{22,32},{22,6},{12,6}}, color={255,0,255}));
  connect(expTanCW.ports[1], pumCW.port_a) annotation (Line(points={{-24,-20},{
          -20,-20},{-20,-50},{-10,-50}},
                                     color={0,127,255}));
  connect(mulChiSys.TSet, TCHWSupSet) annotation (Line(points={{12,10},{20,10},{
          20,24},{-150,24}}, color={0,0,127}));
  connect(priPumCHW.port_b, mulChiSys.port_a2) annotation (Line(points={{-10,50},
          {-22,50},{-22,16},{-10,16}}, color={0,127,255}));
  connect(chiOn.y,priPumSpe.chiOn)  annotation (Line(points={{-59,60},{-48,60},
          {-48,32},{-136,32},{-136,-1},{-121,-1}},     color={255,0,255}));
  connect(actPri.m_flow, chiStaCon.mChWDis) annotation (Line(points={{126,61},{
          126,78},{-124,78},{-124,62},{-119,62}}, color={0,0,127}));
  connect(senTCHWRet.T, chiStaCon.TDisRet) annotation (Line(points={{78,61},{78,
          88},{-132,88},{-132,66},{-119,66}},     color={0,0,127}));
  connect(senTCHWSup.T, chiStaCon.TDisSup) annotation (Line(points={{130,-39},{
          130,24},{92,24},{92,96},{-134,96},{-134,56},{-119,56}}, color={0,0,127}));
  connect(pumCW.port_b, mulChiSys.port_a1) annotation (Line(points={{10,-50},{30,
          -50},{30,4},{10,4}}, color={0,127,255}));
  connect(deCou.m_flow,priPumSpe. deCou) annotation (Line(points={{49,26},{-130,
          26},{-130,-14},{-121,-14}},               color={0,0,127}));
  connect(expTan.ports[1], priPumCHW.port_a)
    annotation (Line(points={{34,66},{10,66},{10,50}}, color={0,127,255}));
  connect(deCou.port_b, senTCHWRet.port_b)
    annotation (Line(points={{60,36},{60,50},{68,50}}, color={0,127,255}));
  connect(senTCHWRet.port_a, actPri.port_b)
    annotation (Line(points={{88,50},{116,50}}, color={0,127,255}));
  connect(port_a, actPri.port_a)
    annotation (Line(points={{160,50},{136,50}}, color={0,127,255}));
  connect(senTCHWRet.port_b, priPumCHW.port_a)
    annotation (Line(points={{68,50},{10,50}}, color={0,127,255}));
  connect(mulChiSys.port_b2, senTCHWSup.port_a) annotation (Line(points={{10,16},
          {60,16},{60,-50},{120,-50}}, color={0,127,255}));
  connect(mulChiSys.port_b2, deCou.port_a)
    annotation (Line(points={{10,16},{60,16}}, color={0,127,255}));
  connect(priPumSpe.priFlo, priFlo.y) annotation (Line(points={{-121,-18},{-130,
          -18},{-130,-34},{-121,-34}}, color={0,0,127}));
  connect(priPumSpe.yPriPum, priPumCHW.u) annotation (Line(points={{-99,-10},{
          -44,-10},{-44,62},{24,62},{24,54},{12,54}},color={0,0,127}));
  connect(chiStaCon.y, priPumSpe.yChi) annotation (Line(points={{-97,53},{-90,
          53},{-90,36},{-126,36},{-126,-10.2},{-121,-10.2}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-140,-80},{160,100}})),
     Icon(coordinateSystem(extent={{-100,-100},{100,100}}),    graphics={
                                Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Polygon(
          points={{-62,-14},{-62,-14}},
          lineColor={238,46,47},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{80,-60},{-80,-60},{-80,60},{-60,60},{-60,0},{-40,0},{-40,20},
              {0,0},{0,20},{40,0},{40,20},{80,0},{80,-60}},
          lineColor={95,95,95},
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{46,-38},{58,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{62,-38},{74,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{62,-54},{74,-42}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{46,-54},{58,-42}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{22,-54},{34,-42}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{6,-54},{18,-42}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{6,-38},{18,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{22,-38},{34,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-18,-54},{-6,-42}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-34,-54},{-22,-42}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-34,-38},{-22,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-18,-38},{-6,-26}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-149,-114},{151,-154}},
          lineColor={0,0,255},
          textString="%name")}),
    Documentation(info="<html>

</html>", revisions="<html>
<ul>
<li>
February 8, 2021, by Hagar Elarga:<br/>
First implementation.
</li>
</ul>
</html>"));
end OSU_CoolingPlant;
