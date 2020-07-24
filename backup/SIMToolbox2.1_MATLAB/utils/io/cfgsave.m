function cfgsave(filename, imginfo, cfg)
    
c.id = 'SIM_config';           % ID
c.ver = cfg.ver;               % sw version
c.time = datestr(now);         % time stamp
c.datadir = imginfo.data.dir;   % data dir
c.filemask = imginfo.data.filemask; % file mask
c.cal = cfg.cal;               % calibration
c.ptrn = cfg.ptrn;             % pattern
c.sim = cfg.sim;               % sr-sim processing
c.msm = cfg.msm;               % map-sim processing
c.vsm = cfg.vsm;               % os-sim processing
c.vsm.eval = {c.vsm.eval([c.vsm.eval.enable]>0).fnc};

% save to file
YAML.write(filename, c);
