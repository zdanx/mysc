-- LocalScript | StarterPlayerScripts/CinematicCamera

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local camera      = workspace.CurrentCamera

local State = {
	Active              = false,
	CurrentMode         = "Orbit",
	Target              = nil,
	TargetMode          = "Self",
	CustomTargetPart    = nil,
	StageCenter         = Vector3.new(0, 5, 0),
	MultiTarget         = false,
	MultiTargetList     = {},
	MultiTargetIdx      = 1,
	MultiTargetLastSwitch = 0,
	MasterFOV           = 70,
	Smoothness          = 4,
	MasterSpeed         = 1,
	DistanceMult        = 1,
	HeightOffset        = 0,
	FollowSmoothness    = 6,
	AutoSwitch          = false,
	AutoInterval        = 6,
	AutoOrder           = "Sequential",
	ModePool            = {},
	LastSwitch          = 0,
	Letterbox           = false,
	LetterboxSize       = 0.12,
	Vignette            = false,
	VignetteIntensity   = 0.5,
	Bloom               = false,
	BloomIntensity      = 1,
	ColorGrade          = "Off",
	DOF                 = false,
	DOFDistance         = 20,
	DOFBlur             = 5,
	MotionBlur          = false,
	ChromaticAberration = false,
	FilmGrain           = false,
	GrainIntensity      = 0.3,
	ShakeIntensity      = 0,
	ShakeDecay          = 0,
	SlowMo              = false,
	FlashTransitions    = false,
	FadeTransitions     = false,
	StartAngle          = "Front",
	CustomAngleDeg      = 0,
	RespectPlayerFacing = true,
	ModeSettings        = {},
	StartTime           = 0,
	ModeStartTime       = 0,
	SmoothCF            = CFrame.new(),
	SmoothFOV           = 70,
	Paused              = false,
	BPM                 = 120,
	OriginalCameraType  = nil,
	OriginalFOV         = 70,
}

local DefaultModeSettings = {
	RevealPushIn    = { radius=30, height=4,  speed=0.15, fov=60  },
	DroneSwoop      = { radius=25, height=15, speed=0.6,  fov=70  },
	HelixRise       = { radius=12, height=2,  speed=0.5,  fov=65  },
	ThroughCrowd    = { radius=20, height=2,  speed=0.4,  fov=80  },
	Orbit           = { radius=14, height=4,  speed=0.3,  fov=55  },
	FPVDrone        = { radius=10, height=5,  speed=0.8,  fov=85  },
	Floating        = { radius=10, height=5,  speed=0.15, fov=65  },
	BirdEyeSweep    = { radius=8,  height=20, speed=0.5,  fov=75  },
	DollyZoom       = { radius=15, height=3,  speed=0.3,  fov=70  },
	CrashZoom       = { radius=20, height=3,  speed=1.2,  fov=70  },
	SmearCam        = { radius=12, height=3,  speed=2.5,  fov=60  },
	WhipSnap        = { radius=13, height=3,  speed=2,    fov=55  },
	PunchIn         = { radius=8,  height=2.5,speed=1,    fov=35  },
	StrobeCut       = { radius=12, height=3,  speed=3,    fov=55  },
	BounceBeat      = { radius=11, height=3,  speed=2.5,  fov=58  },
	GlitchCam       = { radius=10, height=3,  speed=2,    fov=55  },
	SpeedRamp       = { radius=15, height=4,  speed=1,    fov=60  },
	SlowMoDrop      = { radius=10, height=3,  speed=0.1,  fov=45  },
	FrozenOrbit     = { radius=8,  height=3,  speed=0.15, fov=40  },
	VertigoDolly    = { radius=15, height=3,  speed=0.4,  fov=60  },
	RocketPullback  = { radius=8,  height=4,  speed=1.5,  fov=40  },
	SpinReveal      = { radius=10, height=3,  speed=2,    fov=55  },
	TunnelWarp      = { radius=12, height=3,  speed=1,    fov=90  },
	FishEye         = { radius=8,  height=3,  speed=0.3,  fov=105 },
	Silhouette      = { radius=12, height=3,  speed=0.2,  fov=50  },
	ColorPop        = { radius=10, height=3,  speed=0.25, fov=55  },
	Kaleidoscope    = { radius=10, height=3,  speed=0.4,  fov=60  },
	VHSCam          = { radius=10, height=3,  speed=0.3,  fov=65  },
	HeadStaticShot  = { radius=5,  height=3.2,speed=0,    fov=42  },
	BodyStaticShot  = { radius=9,  height=2.4,speed=0,    fov=58  },
	SideStaticShot  = { radius=8,  height=2.2,speed=0,    fov=55  },
	HighRightShot   = { radius=11, height=7,  speed=0,    fov=62  },
	FootStaticShot  = { radius=6,  height=0.8,speed=0,    fov=50  },
	DutchTiltShot   = { radius=8,  height=2.6,speed=0,    fov=55  },
	UpsideDownShot  = { radius=8,  height=2.6,speed=0,    fov=58  },
	BackLowShot     = { radius=7,  height=1.1,speed=0,    fov=60  },
	MVAutoDirector  = { radius=12, height=4,  speed=1,    fov=60  },
}

local ModeOrder = {
	"RevealPushIn","DroneSwoop","HelixRise","ThroughCrowd",
	"Orbit","FPVDrone","Floating","BirdEyeSweep","DollyZoom",
	"CrashZoom","SmearCam","WhipSnap","PunchIn",
	"StrobeCut","BounceBeat","GlitchCam",
	"SpeedRamp","SlowMoDrop","FrozenOrbit",
	"VertigoDolly","RocketPullback","SpinReveal","TunnelWarp",
	"FishEye","Silhouette","ColorPop","Kaleidoscope","VHSCam",
	"HeadStaticShot","BodyStaticShot","SideStaticShot",
	"HighRightShot","FootStaticShot","DutchTiltShot",
	"UpsideDownShot","BackLowShot","MVAutoDirector",
}

local ModeMeta = {
	RevealPushIn   = { phase="Intro",     label="Reveal Push-In"   },
	DroneSwoop     = { phase="Intro",     label="Drone Swoop"      },
	HelixRise      = { phase="Intro",     label="Helix Rise"       },
	ThroughCrowd   = { phase="Intro",     label="Through Crowd"    },
	Orbit          = { phase="Groove",    label="Orbit"            },
	FPVDrone       = { phase="Groove",    label="FPV Drone"        },
	Floating       = { phase="Groove",    label="Floating"         },
	BirdEyeSweep   = { phase="Groove",    label="Bird Eye Sweep"   },
	DollyZoom      = { phase="Groove",    label="Dolly Zoom"       },
	CrashZoom      = { phase="Drop",      label="Crash Zoom"       },
	SmearCam       = { phase="Drop",      label="Smear Cam"        },
	WhipSnap       = { phase="Drop",      label="Whip Snap"        },
	PunchIn        = { phase="Drop",      label="Punch In"         },
	StrobeCut      = { phase="Beat",      label="Strobe Cut"       },
	BounceBeat     = { phase="Beat",      label="Bounce Beat"      },
	GlitchCam      = { phase="Beat",      label="Glitch Cam"       },
	SpeedRamp      = { phase="Ramp",      label="Speed Ramp"       },
	SlowMoDrop     = { phase="Ramp",      label="Slow Mo Drop"     },
	FrozenOrbit    = { phase="Ramp",      label="Frozen Orbit"     },
	VertigoDolly   = { phase="Cinematic", label="Vertigo Dolly"    },
	RocketPullback = { phase="Cinematic", label="Rocket Pullback"  },
	SpinReveal     = { phase="Cinematic", label="Spin Reveal"      },
	TunnelWarp     = { phase="Cinematic", label="Tunnel Warp"      },
	FishEye        = { phase="FX",        label="Fish Eye"         },
	Silhouette     = { phase="FX",        label="Silhouette"       },
	ColorPop       = { phase="FX",        label="Color Pop"        },
	Kaleidoscope   = { phase="FX",        label="Kaleidoscope"     },
	VHSCam         = { phase="FX",        label="VHS Cam"          },
	HeadStaticShot = { phase="Static",    label="Head Shot"        },
	BodyStaticShot = { phase="Static",    label="Body Shot"        },
	SideStaticShot = { phase="Static",    label="Side Shot"        },
	HighRightShot  = { phase="Static",    label="High Right"       },
	FootStaticShot = { phase="Static",    label="Foot Shot"        },
	DutchTiltShot  = { phase="Static",    label="Dutch Tilt"       },
	UpsideDownShot = { phase="Static",    label="Upside Down"      },
	BackLowShot    = { phase="Static",    label="Back Low"         },
	MVAutoDirector = { phase="Auto",      label="MV Auto Director" },
}

for name, def in pairs(DefaultModeSettings) do
	State.ModeSettings[name] = { radius=def.radius, height=def.height, speed=def.speed, fov=def.fov }
end

local bloomFX, dofFX, colorFX
do
	bloomFX = Instance.new("BloomEffect")
	bloomFX.Enabled = false
	bloomFX.Parent  = Lighting

	dofFX = Instance.new("DepthOfFieldEffect")
	dofFX.Enabled = false
	dofFX.Parent  = Lighting

	colorFX = Instance.new("ColorCorrectionEffect")
	colorFX.Enabled = false
	colorFX.Parent  = Lighting
end

local function getTarget()
	if State.MultiTarget and #State.MultiTargetList > 0 then
		local now = os.clock()
		if now - State.MultiTargetLastSwitch >= State.AutoInterval * 0.5 then
			State.MultiTargetIdx = State.MultiTargetIdx % #State.MultiTargetList + 1
			State.MultiTargetLastSwitch = now
			State.CustomTargetPart = State.MultiTargetList[State.MultiTargetIdx]
		end
		return State.CustomTargetPart
	end
	if State.TargetMode == "Custom" and State.CustomTargetPart and State.CustomTargetPart.Parent then
		return State.CustomTargetPart
	end
	if State.TargetMode == "Stage" then return nil end
	local char = localPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getTargetPos()
	local t = getTarget()
	if t then return t.Position end
	return State.StageCenter
end

local function getSettings()
	return State.ModeSettings[State.CurrentMode] or DefaultModeSettings[State.CurrentMode] or { radius=12, height=4, speed=0.5, fov=60 }
end

local function getStartAngle()
	if State.StartAngle == "Custom" then
		return math.rad(State.CustomAngleDeg)
	end
	if State.StartAngle == "Front" and State.RespectPlayerFacing then
		local char = localPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local _, ry, _ = root.CFrame:ToEulerAnglesYXZ()
			return ry + math.pi
		end
	end
	return 0
end

local angleAccum = 0
local helixHeight = 0
local dollyDir   = 1
local glitchTimer = 0
local strobeTimer = 0
local strobeState = false
local grainFrame  = 0

local function computeCameraCF(dt)
	local s       = getSettings()
	local tPos    = getTargetPos()
	local t       = os.clock() - State.ModeStartTime
	local spd     = s.speed * State.MasterSpeed
	local rad     = s.radius * State.DistanceMult
	local ht      = s.height + State.HeightOffset
	local fov     = math.min(s.fov, State.MasterFOV)
	local mode    = State.CurrentMode
	local angle   = angleAccum
	local camCF   = State.SmoothCF
	local targetFOV = fov

	if mode == "RevealPushIn" then
		local pushRad = rad - t * 4
		pushRad = math.max(pushRad, rad * 0.35)
		local cx = tPos.X + math.cos(angle) * pushRad
		local cz = tPos.Z + math.sin(angle) * pushRad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "DroneSwoop" then
		angleAccum = angleAccum + spd * dt
		local swoopHt = ht - math.min(t * 2, ht * 0.7)
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + swoopHt, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "HelixRise" then
		angleAccum = angleAccum + spd * dt
		helixHeight = helixHeight + dt * 1.5
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht + helixHeight, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "ThroughCrowd" then
		angleAccum = angleAccum + spd * dt
		local side = math.sin(t * 0.8) * rad * 0.5
		local cx = tPos.X + math.cos(angle) * rad * 0.4 + side
		local cz = tPos.Z + math.sin(angle) * rad * 0.4
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "Orbit" then
		angleAccum = angleAccum + spd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "FPVDrone" then
		angleAccum = angleAccum + spd * dt
		local wobbleY = math.sin(t * 1.8) * 0.6
		local wobbleX = math.cos(t * 2.1) * 0.4
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(
			Vector3.new(cx + wobbleX, tPos.Y + ht + wobbleY, cz),
			tPos + Vector3.new(0,2,0)
		) * CFrame.Angles(0, 0, math.sin(t * 1.3) * 0.04)

	elseif mode == "Floating" then
		angleAccum = angleAccum + spd * dt
		local floatY = math.sin(t * 0.5) * 0.8
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht + floatY, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "BirdEyeSweep" then
		angleAccum = angleAccum + spd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos)

	elseif mode == "DollyZoom" then
		angleAccum = angleAccum + spd * dt
		local dRad = rad + math.sin(t * 0.4) * rad * 0.3
		local dFov = fov + math.sin(t * 0.4 + math.pi) * 15
		targetFOV = math.clamp(dFov, 20, 120)
		local cx = tPos.X + math.cos(angle) * dRad
		local cz = tPos.Z + math.sin(angle) * dRad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "CrashZoom" then
		angleAccum = angleAccum + spd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "SmearCam" then
		angleAccum = angleAccum + spd * dt
		local smear = math.sin(t * spd * 6) * 0.08
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))
			* CFrame.Angles(0, smear, smear * 0.5)

	elseif mode == "WhipSnap" then
		angleAccum = angleAccum + spd * dt
		local snap = math.floor(t * 2) * 0.5
		local cx = tPos.X + math.cos(snap) * rad
		local cz = tPos.Z + math.sin(snap) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "PunchIn" then
		angleAccum = angleAccum + spd * dt
		local pulse = 1 + math.abs(math.sin(t * 4)) * 0.15
		local cx = tPos.X + math.cos(angle) * rad * pulse
		local cz = tPos.Z + math.sin(angle) * rad * pulse
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,1.5,0))

	elseif mode == "StrobeCut" then
		strobeTimer = strobeTimer + dt
		local bps = State.BPM / 60
		if strobeTimer >= 1 / bps then
			strobeTimer = 0
			strobeState = not strobeState
			local offsets = { Vector3.new(rad,ht,0), Vector3.new(-rad,ht,rad*0.5), Vector3.new(0,ht+4,-rad) }
			local pick = offsets[math.random(1, #offsets)]
			camCF = CFrame.lookAt(tPos + pick, tPos + Vector3.new(0,2,0))
		else
			camCF = State.SmoothCF
		end

	elseif mode == "BounceBeat" then
		local bps = State.BPM / 60
		local bounce = math.abs(math.sin(t * bps * math.pi)) * 1.5
		angleAccum = angleAccum + spd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht + bounce, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "GlitchCam" then
		glitchTimer = glitchTimer + dt
		angleAccum = angleAccum + spd * dt
		local jx, jy = 0, 0
		if glitchTimer > 0.12 then
			glitchTimer = 0
			jx = (math.random() - 0.5) * 2.5
			jy = (math.random() - 0.5) * 1.5
		end
		local cx = tPos.X + math.cos(angle) * rad + jx
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht + jy, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "SpeedRamp" then
		local rampSpd = spd * (1 + math.sin(t * 0.5) * 0.8)
		angleAccum = angleAccum + rampSpd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "SlowMoDrop" then
		angleAccum = angleAccum + spd * dt
		local dropHt = ht + math.max(0, 8 - t * 0.5)
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + dropHt, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "FrozenOrbit" then
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "VertigoDolly" then
		local pull = rad + t * 1.5
		local vFov = fov - t * 1.2
		targetFOV = math.clamp(vFov, 20, 120)
		local cx = tPos.X + math.cos(angle) * pull
		local cz = tPos.Z + math.sin(angle) * pull
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "RocketPullback" then
		local pull = rad + t * spd * 12
		local cx = tPos.X + math.cos(angle) * pull
		local cz = tPos.Z + math.sin(angle) * pull
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y + ht + t * 2, cz), tPos + Vector3.new(0,2,0))

	elseif mode == "SpinReveal" then
		angleAccum = angleAccum + spd * dt
		camCF = CFrame.lookAt(Vector3.new(tPos.X + math.cos(angle)*rad, tPos.Y+ht, tPos.Z+math.sin(angle)*rad), tPos+Vector3.new(0,2,0))
			* CFrame.Angles(0, 0, math.sin(t * spd * 2) * 0.3)

	elseif mode == "TunnelWarp" then
		angleAccum = angleAccum + spd * dt
		local warpFov = fov + math.sin(t * 2) * 18
		targetFOV = math.clamp(warpFov, 20, 120)
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))

	elseif mode == "FishEye" then
		angleAccum = angleAccum + spd * dt
		targetFOV = fov
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))

	elseif mode == "Silhouette" then
		angleAccum = angleAccum + spd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))

	elseif mode == "ColorPop" then
		angleAccum = angleAccum + spd * dt
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))

	elseif mode == "Kaleidoscope" then
		angleAccum = angleAccum + spd * dt
		local roll = math.sin(t * 0.8) * 0.25
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))
			* CFrame.Angles(0, 0, roll)

	elseif mode == "VHSCam" then
		angleAccum = angleAccum + spd * dt
		local vhsX = math.sin(t * 7) * 0.08
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx+vhsX, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))

	elseif mode == "HeadStaticShot" then
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2.5,0))

	elseif mode == "BodyStaticShot" then
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,1,0))

	elseif mode == "SideStaticShot" then
		local sideAngle = angle + math.pi * 0.5
		local cx = tPos.X + math.cos(sideAngle) * rad
		local cz = tPos.Z + math.sin(sideAngle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,1.5,0))

	elseif mode == "HighRightShot" then
		local hrAngle = angle + math.pi * 0.25
		local cx = tPos.X + math.cos(hrAngle) * rad
		local cz = tPos.Z + math.sin(hrAngle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,1,0))

	elseif mode == "FootStaticShot" then
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,0,0))

	elseif mode == "DutchTiltShot" then
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,1.5,0))
			* CFrame.Angles(0, 0, math.rad(14))

	elseif mode == "UpsideDownShot" then
		local cx = tPos.X + math.cos(angle) * rad
		local cz = tPos.Z + math.sin(angle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,1.5,0))
			* CFrame.Angles(0, 0, math.pi)

	elseif mode == "BackLowShot" then
		local backAngle = angle + math.pi
		local cx = tPos.X + math.cos(backAngle) * rad
		local cz = tPos.Z + math.sin(backAngle) * rad
		camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))

	elseif mode == "MVAutoDirector" then
		angleAccum = angleAccum + spd * dt
		local mvSwitch = math.floor(t / 3) % 4
		if mvSwitch == 0 then
			local cx = tPos.X + math.cos(angle) * rad
			local cz = tPos.Z + math.sin(angle) * rad
			camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))
		elseif mvSwitch == 1 then
			local cx = tPos.X + math.cos(angle) * rad * 0.5
			local cz = tPos.Z + math.sin(angle) * rad * 0.5
			camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht*0.6, cz), tPos+Vector3.new(0,1.5,0))
		elseif mvSwitch == 2 then
			camCF = CFrame.lookAt(Vector3.new(tPos.X, tPos.Y+ht*3, tPos.Z), tPos)
		else
			local sAngle = angle + math.pi * 0.5
			local cx = tPos.X + math.cos(sAngle) * rad
			local cz = tPos.Z + math.sin(sAngle) * rad
			camCF = CFrame.lookAt(Vector3.new(cx, tPos.Y+ht, cz), tPos+Vector3.new(0,2,0))
		end
	end

	if State.ShakeIntensity > 0.001 then
		local si = State.ShakeIntensity
		camCF = camCF * CFrame.new(
			(math.random()-0.5)*si,
			(math.random()-0.5)*si,
			(math.random()-0.5)*si
		)
		State.ShakeIntensity = State.ShakeIntensity * (1 - State.ShakeDecay * dt * 10)
	end

	return camCF, targetFOV
end

local function applyFX()
	bloomFX.Enabled   = State.Bloom and State.Active
	bloomFX.Intensity = State.BloomIntensity

	dofFX.Enabled      = State.DOF and State.Active
	dofFX.FocusDistance = State.DOFDistance
	dofFX.InFocusRadius = State.DOFBlur

	colorFX.Enabled = State.ColorGrade ~= "Off" and State.Active
	if State.ColorGrade == "Warm" then
		colorFX.TintColor = Color3.fromRGB(255, 220, 180)
		colorFX.Contrast  = 0.1
		colorFX.Saturation = 0.15
	elseif State.ColorGrade == "Cool" then
		colorFX.TintColor = Color3.fromRGB(180, 210, 255)
		colorFX.Contrast  = 0.05
		colorFX.Saturation = 0.05
	elseif State.ColorGrade == "Noir" then
		colorFX.TintColor = Color3.fromRGB(255, 255, 255)
		colorFX.Contrast  = 0.3
		colorFX.Saturation = -1
	elseif State.ColorGrade == "Vivid" then
		colorFX.TintColor = Color3.fromRGB(255, 255, 255)
		colorFX.Contrast  = 0.2
		colorFX.Saturation = 0.5
	end
end

local function setMode(name, fromUser)
	if not DefaultModeSettings[name] then return end
	State.CurrentMode    = name
	State.ModeStartTime  = os.clock()
	angleAccum  = getStartAngle()
	helixHeight = 0
	dollyDir    = 1
	glitchTimer = 0
	strobeTimer = 0
	applyFX()
	if _G.CinematicUI and _G.CinematicUI.OnModeChange then
		_G.CinematicUI.OnModeChange(name)
	end
end

local function startCinematic()
	if State.Active then return end
	State.Active             = true
	State.OriginalCameraType = camera.CameraType
	State.OriginalFOV        = camera.FieldOfView
	State.StartTime          = os.clock()
	State.ModeStartTime      = os.clock()
	camera.CameraType        = Enum.CameraType.Scriptable
	angleAccum               = getStartAngle()
	helixHeight              = 0
	applyFX()
	if _G.CinematicUI and _G.CinematicUI.OnStart then
		_G.CinematicUI.OnStart()
	end
end

local function stopCinematic()
	if not State.Active then return end
	State.Active      = false
	camera.CameraType = State.OriginalCameraType or Enum.CameraType.Custom
	camera.FieldOfView = State.OriginalFOV
	bloomFX.Enabled   = false
	dofFX.Enabled     = false
	colorFX.Enabled   = false
	if _G.CinematicUI and _G.CinematicUI.OnStop then
		_G.CinematicUI.OnStop()
	end
end

local function doAutoSwitch()
	if not State.AutoSwitch then return end
	local now = os.clock()
	if now - State.LastSwitch < State.AutoInterval then return end
	State.LastSwitch = now

	local pool = {}
	if State.AutoOrder == "Sequential" then
		for _, n in ipairs(ModeOrder) do table.insert(pool, n) end
	elseif State.AutoOrder == "Phase" then
		local phase = ModeMeta[State.CurrentMode] and ModeMeta[State.CurrentMode].phase
		for _, n in ipairs(ModeOrder) do
			if ModeMeta[n] and ModeMeta[n].phase == phase then
				table.insert(pool, n)
			end
		end
	else
		for n, v in pairs(State.ModePool) do
			if v then table.insert(pool, n) end
		end
	end

	if #pool == 0 then return end

	if State.AutoOrder == "Sequential" then
		local idx = table.find(pool, State.CurrentMode) or 0
		local next = pool[idx % #pool + 1]
		setMode(next, false)
	else
		setMode(pool[math.random(1, #pool)], false)
	end
end

RunService.RenderStepped:Connect(function(dt)
	if not State.Active or State.Paused then return end
	doAutoSwitch()

	local targetCF, targetFOV = computeCameraCF(dt)
	local alpha = math.clamp(dt * State.Smoothness, 0, 1)
	State.SmoothCF  = State.SmoothCF:Lerp(targetCF, alpha)
	State.SmoothFOV = State.SmoothFOV + (targetFOV - State.SmoothFOV) * alpha
	camera.CFrame       = State.SmoothCF
	camera.FieldOfView  = State.SmoothFOV
end)

local function collectOtherRoots()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= localPlayer then
			local char = p.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then table.insert(t, root) end
		end
	end
	return t
end

local function getNearestRoot(maxDist)
	local char = localPlayer.Character
	local selfRoot = char and char:FindFirstChild("HumanoidRootPart")
	if not selfRoot then return nil end
	local best, bestDist = nil, maxDist or 200
	for _, r in ipairs(collectOtherRoots()) do
		local d = (r.Position - selfRoot.Position).Magnitude
		if d < bestDist then best, bestDist = r, d end
	end
	return best
end

_G.CinematicCamera = {
	State               = State,
	ModeOrder           = ModeOrder,
	ModeMeta            = ModeMeta,
	DefaultModeSettings = DefaultModeSettings,
	Start               = startCinematic,
	Stop                = stopCinematic,
	Toggle              = function()
		if State.Active then stopCinematic() else startCinematic() end
	end,
	Pause               = function() State.Paused = true  end,
	Resume              = function() State.Paused = false end,
	SetMode             = function(n) setMode(n, true)    end,
	NextMode            = function()
		local idx = table.find(ModeOrder, State.CurrentMode) or 1
		setMode(ModeOrder[idx % #ModeOrder + 1], true)
	end,
	PrevMode            = function()
		local idx = table.find(ModeOrder, State.CurrentMode) or 1
		setMode(ModeOrder[(idx - 2) % #ModeOrder + 1], true)
	end,
	Shake               = function(i, d) State.ShakeIntensity = i or 0.5; State.ShakeDecay = d or 0.4 end,
	SetLetterbox        = function(v, sz)
		State.Letterbox = v
		if sz then State.LetterboxSize = sz end
		if _G.CinematicUI and _G.CinematicUI.SetLetterbox then
			_G.CinematicUI.SetLetterbox(v)
		end
	end,
	SetTargetMode       = function(m)
		if m == "Self" or m == "Stage" or m == "Custom" then
			State.TargetMode = m
			if m ~= "Custom" then State.MultiTarget = false end
		end
	end,
	SetTarget           = function(p)
		if typeof(p) ~= "Instance" or not p:IsA("BasePart") then return false end
		State.CustomTargetPart = p; State.TargetMode = "Custom"; State.MultiTarget = false
		return true
	end,
	SetSelfTarget       = function() State.TargetMode = "Self"; State.CustomTargetPart = nil; State.MultiTarget = false end,
	SetStageCenter      = function(v) State.StageCenter = v; State.TargetMode = "Stage"; State.MultiTarget = false end,
	SetNearestPlayerTarget = function(d)
		local r = getNearestRoot(d)
		return r and _G.CinematicCamera.SetTarget(r) or false
	end,
	SetMultiTarget      = function(list)
		local valid = {}
		for _, p in ipairs(list or {}) do
			if typeof(p) == "Instance" and p:IsA("BasePart") and p.Parent then
				table.insert(valid, p)
			end
		end
		State.MultiTargetList = valid; State.MultiTargetIdx = 1
		State.MultiTargetLastSwitch = 0; State.MultiTarget = #valid > 0
		if #valid > 0 then State.CustomTargetPart = valid[1]; State.TargetMode = "Custom" end
		return #valid
	end,
	SetAllPlayerTargets = function() return _G.CinematicCamera.SetMultiTarget(collectOtherRoots()) end,
	ClearMultiTarget    = function() State.MultiTarget = false; State.MultiTargetList = {}; State.MultiTargetIdx = 1 end,
	UpdateFX            = applyFX,
	SetBPM              = function(b) State.BPM = b end,
	ResetMode           = function(n)
		local d = DefaultModeSettings[n]
		if d then State.ModeSettings[n] = { radius=d.radius, height=d.height, speed=d.speed, fov=d.fov } end
	end,
	ResetAll            = function()
		for n, d in pairs(DefaultModeSettings) do
			State.ModeSettings[n] = { radius=d.radius, height=d.height, speed=d.speed, fov=d.fov }
		end
		State.MasterFOV = 70; State.Smoothness = 4; State.MasterSpeed = 1
		State.DistanceMult = 1; State.HeightOffset = 0
	end,
	LoadPreset          = function(name)
		local presets = _G.CinematicCamera.Presets
		if presets and presets[name] then presets[name]() end
		applyFX()
	end,
	Presets             = {
		Hype = function()
			State.FlashTransitions = true
			State.AutoSwitch = true; State.AutoInterval = 2; State.AutoOrder = "Random"
			for _, n in ipairs(ModeOrder) do State.ModePool[n] = false end
			State.ModePool.StrobeCut = true; State.ModePool.CrashZoom = true
			State.ModePool.SmearCam  = true; State.ModePool.WhipSnap  = true
			setMode("StrobeCut", false)
		end,
		Chill = function()
			State.Letterbox = true; State.LetterboxSize = 0.1
			State.ColorGrade = "Cool"; State.Smoothness = 2.5
			State.AutoSwitch = true; State.AutoInterval = 12; State.AutoOrder = "Sequential"
			for _, n in ipairs(ModeOrder) do State.ModePool[n] = false end
			State.ModePool.Floating = true; State.ModePool.Orbit = true
			State.ModePool.SlowMoDrop = true; State.ModePool.FrozenOrbit = true
			setMode("Floating", false)
		end,
		Cinematic = function()
			State.Letterbox = true; State.LetterboxSize = 0.15
			State.Vignette = true; State.VignetteIntensity = 0.6
			State.FilmGrain = true; State.GrainIntensity = 0.3
			State.ColorGrade = "Noir"; State.FadeTransitions = true
			State.AutoSwitch = true; State.AutoInterval = 6; State.AutoOrder = "Phase"
			setMode("VertigoDolly", false)
		end,
	},
}

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.C then
		_G.CinematicCamera.Toggle()
	elseif State.Active then
		if input.KeyCode == Enum.KeyCode.X then
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				_G.CinematicCamera.PrevMode()
			else
				_G.CinematicCamera.NextMode()
			end
		elseif input.KeyCode == Enum.KeyCode.B then
			_G.CinematicCamera.Shake(0.7, 0.5)
		elseif input.KeyCode == Enum.KeyCode.N then
			_G.CinematicCamera.SetLetterbox(not State.Letterbox)
		elseif input.KeyCode == Enum.KeyCode.M then
			State.AutoSwitch = not State.AutoSwitch
		elseif input.KeyCode == Enum.KeyCode.Space then
			State.Paused = not State.Paused
		end
	end
end)
