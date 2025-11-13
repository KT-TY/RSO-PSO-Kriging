function glv = global_paramater_switch(model)
    %% 旋转椭球体四参数
    if ~exist('model', 'var'), model = 'CGCS2000'; end
    glv = [];

    switch model
        case 'WGS84'
            % WGS84-4参数
            glv.Re = 6378137;
            glv.wie = 7.292115e-5;
            glv.f = 1 / 298.257223563;
            glv.GM = 3.986004418e14;
        case 'GRS80'
            % GRS80-4参数
            glv.Re = 6378140;
            glv.wie = 7.292115e-5;
            glv.f = 1 / 298.25722101;
            glv.GM = 3.986005e14;
        case 'CGCS2000'
            % CGCS-2000-4参数
            glv.Re = 6378137;
            glv.wie = 7.292115e-5;
            glv.f = 1 / 298.257222101;
            glv.GM = 3.986004418e14;
        otherwise, error('Please definite mode of earth');
    end

    %% 地球参数-重力参数: Rp e e' J2 g0
    glv = shape_paramater(glv);
    glv = gravity_paramater(glv);
    glv.J2n = @Jn_recursive;

    %% glvf未改动参数
    glv.meru = glv.wie / 1000; % milli earth rate unit
    glv.mg = 1.0e-3 * glv.g0; % milli g
    glv.ug = 1.0e-6 * glv.g0; % micro g
    glv.mGal = 1.0e-3 * 0.01; % milli Gal = 1cm/s^2 ~= 1.0E-6*g0
    glv.uGal = glv.mGal / 1000; % micro Gal
    glv.ugpg2 = glv.ug / glv.g0 ^ 2; % ug/g^2
    glv.ws = 1 / sqrt(glv.Re / glv.g0); % Schuler frequency
    glv.ppm = 1.0e-6; % parts per million
    glv.deg = pi / 180; % arcdeg
    glv.min = glv.deg / 60; % arcmin
    glv.sec = glv.min / 60; % arcsec
    glv.mas = glv.sec / 1000; % milli arcsec
    glv.hur = 3600; % time hour (1hur=3600second)
    glv.dps = pi / 180 / 1; % arcdeg / second
    glv.rps = 360 * glv.dps; % revolutions per second
    glv.dph = glv.deg / glv.hur; % arcdeg / hour
    glv.dpss = glv.deg / sqrt(1); % arcdeg / sqrt(second)
    glv.dpsh = glv.deg / sqrt(glv.hur); % arcdeg / sqrt(hour)
    glv.dphpsh = glv.dph / sqrt(glv.hur); % (arcdeg/hour) / sqrt(hour)
    glv.dph2 = glv.dph / glv.hur; % (arcdeg/hour) / hour
    glv.Hz = 1 / 1; % Hertz
    glv.dphpsHz = glv.dph / glv.Hz; % (arcdeg/hour) / sqrt(Hz)
    glv.dphpg = glv.dph / glv.g0; % (arcdeg/hour) / g
    glv.dphpg2 = glv.dphpg / glv.g0; % (arcdeg/hour) / g^2
    glv.ugpsHz = glv.ug / sqrt(glv.Hz); % ug / sqrt(Hz)
    glv.ugpsh = glv.ug / sqrt(glv.hur); % ug / sqrt(hour)
    glv.mpsh = 1 / sqrt(glv.hur); % m / sqrt(hour)
    glv.mpspsh = 1 / 1 / sqrt(glv.hur); % (m/s) / sqrt(hour), 1*mpspsh~=1700*ugpsHz
    glv.ppmpsh = glv.ppm / sqrt(glv.hur); % ppm / sqrt(hour)
    glv.mil = 2 * pi / 6000; % mil
    glv.nm = 1853; % nautical mile
    glv.kn = glv.nm / glv.hur; % knot
    glv.kmph = 1000 / glv.hur; % km/hour

    glv.wm_1 = [0, 0, 0]; glv.vm_1 = [0, 0, 0]; % the init of previous gyro & acc sample
    glv.cs = [                          % coning & sculling compensation coefficients
        [2, 0, 0, 0, 0    ] / 3
        [9, 27, 0, 0, 0    ] / 20
        [54, 92, 214, 0, 0    ] / 105
        [250, 525, 650, 1375, 0    ] / 504
        [2315, 4558, 7296, 7834, 15797] / 4620 ];
    glv.csmax = size(glv.cs, 1) + 1; % max subsample number
    glv.v0 = [0; 0; 0]; % 3x1 zero-vector
    glv.qI = [1; 0; 0; 0]; % identity quaternion
    glv.I33 = eye(3); glv.o33 = zeros(3); % identity & zero 3x3 matrices
    glv.pos0 = [[34.246048; 108.909664] * glv.deg; 380]; % position of INS Lab@NWPU
    glv.t0 = 0;
    glv.tscale = 1; % =1 for second, =60 for minute, =3600 for hour, =24*3600 for day
    glv.isfig = 1;
    glv.dgn = [];
    [glv.rootpath, glv.datapath, glv.mytestflag] = psinsenvi;
end

%%
function glv = shape_paramater(glv)
    glv.Rp = (1 - glv.f) * glv.Re; % f=(a-b)/a => b=(1-f)a
    glv.e2 = 2 * glv.f - glv.f ^ 2; % e² = (a²-b²)/a² = 2f-f²
    glv.e = sqrt(glv.e2);
    glv.ep2 = glv.e2 / (1 - glv.e2); % e'² = (a²-b²)/b² = e²/(1-e²)
    glv.ep = sqrt(glv.ep2);
    glv.eLine = sqrt(glv.Re ^ 2 - glv.Rp ^ 2); % 线性偏心率
    glv.Rc = (glv.Re ^ 2) / glv.Rp;
    glv.Q = glv.Rc * pi / 2 * (1 - 3 * glv.ep2 / 4 + 45 * (glv.ep2 ^ 2) / 64 ...
        - 175 * (glv.ep2 ^ 3) / 256 + 11025 * (glv.ep2 ^ 4) / 16384); % arc of meridian from equator to pole

    glv.R1 = glv.Re * (1 - glv.f / 3); % arithmetic mean of radius
    glv.R2 = glv.Rc * (1 - 2 * glv.ep2 / 3 + 26 * (glv.ep2 ^ 2) / 45 ...
        - 100 * (glv.ep2 ^ 3) / 189 + 7034 * (glv.ep2 ^ 4) / 14175); % radius of sphere of the same surface
    glv.R3 = nthroot((glv.Re ^ 2) * glv.Rp, 3); % radius of sphere of the same volume
end

function glv = gravity_paramater(glv)
    q02 = (1 + 3 / glv.ep2) * atan(glv.ep) - 3 / glv.ep;
    q0p = 3 * (1 + 1 / glv.ep2) * (1 - 1 / glv.ep * atan(glv.ep)) - 1;
    m = (glv.wie ^ 2) * (glv.Re ^ 2) * glv.Rp / glv.GM;
    mep = (glv.wie ^ 2) * (glv.Re ^ 3) * glv.e / glv.GM; % me' = w²a²be'/GM = w²a³e/GM

    glv.J2 = glv.e2 / 3 * (1 - 4 * mep / (15 * q02));
    glv.C20 = -glv.J2 / sqrt(5);
    glv.U0 = glv.GM / glv.eLine * atan(glv.ep) + ((glv.Re * glv.wie) ^ 2) / 3;
    glv.g0 = glv.GM * (glv.ep - mep - mep / 3 * glv.ep * q0p / q02) / ((glv.Re ^ 2) * glv.e);
    glv.gp = glv.GM * (1 + 2 * mep * q0p / q02 / 3) / (glv.Re ^ 2);
    glv.gf = (glv.gp - glv.g0) / glv.g0; % gravity flattening
    k = glv.Rp * glv.gp / glv.Re / glv.g0 - 1;

    % g = g0 * (1 + b2 * (sinB)^2 + b4 * (sinB)^4 + b6 * (sinB)^6 + b8 * (sinB)^8) + bh * h;
    % g'|h = 2g0 / Re * (1 + f + m + (2.5m - 3f) * (sinL)^2);
    % bh = bh + bhL * (sinL)^2;
    glv.bh = 2 * glv.g0 * (1 + glv.f + m) / glv.Re;
    glv.bhL = 2 * glv.g0 * (2.5 * m - 3 * glv.f) / glv.Re;
    [glv.b2, glv.b4, glv.b6, glv.b8] = beta_series_expansion(glv.e2, k);
end

function J2n = Jn_recursive(J2, e2, n)
    n = n / 2;
    J2n = ((-1) ^ (n + 1)) * (3 * (e2 ^ n) * (1 - n + 5 * n * J2 / e2)) / ((2 * n + 1) * (2 * n + 3));
end

function [b2, b4, b6, b8] = beta_series_expansion(e2, k)
    b2 = e2 / 2 + k;
    b4 = e2 * (e2 * 3 / 8 + k / 2);
    b6 = (e2 ^ 2) * (e2 * 5 / 16 + k * 3 / 8);
    b8 = (e2 ^ 3) * (e2 * 35 / 128 + k * 5 / 16);
end
