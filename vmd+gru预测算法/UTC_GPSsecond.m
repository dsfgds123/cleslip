function GPS_seconds_of_day = UTC_GPSsecond(UTC_vector)
% UTC_GPSSECOND - 将UTC时间向量转换为GPS当天秒
%
% 这个函数是一个简化的实现，用于解决主程序缺失依赖的问题。
% 它假设UTC和GPS时间之间存在一个固定的闰秒差。
%
% 输入:
%   UTC_vector - 一个包含UTC时间的向量，格式为 [年, 月, 日, 时, 分, 秒]
%
% 输出:
%   GPS_seconds_of_day - 转换后的GPS当天秒

% 定义闰秒（Leap Seconds）
% 自2017年1月1日至今，GPS时比UTC时快18秒。
% 注意：如果您的数据日期早于2017年，这个值可能需要修改。
% (2015-2017: 17s, 2012-2015: 16s, etc.)
LEAP_SECONDS = 18;

% 为了进行日期计算，使用datetime对象
utc_datetime = datetime(UTC_vector);

% GPS时间 = UTC时间 + 闰秒
gps_datetime = utc_datetime + seconds(LEAP_SECONDS);

% 计算GPS时间的当天秒
GPS_seconds_of_day = gps_datetime.Hour * 3600 + gps_datetime.Minute * 60 + gps_datetime.Second;

end